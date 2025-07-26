'use strict';

const { sanitize } = require('@strapi/utils');
const { getService } = require('@strapi/plugin-users-permissions/server/utils');

// 生成邀请码
function generateInviteCode() {
  return Math.random().toString(36).substring(2, 8).toUpperCase();
}

module.exports = (plugin) => {
  // 保留原有所有控制器
  const original = { ...plugin.controllers.auth };

  /**
   * POST /auth/local/register-with-invite
   * 必须携带有效邀请码，且 email/username/password 通过原有校验
   */
  original.registerWithInvite = async (ctx) => {
    const { inviteCode, username, email, password } = ctx.request.body;

    if (!inviteCode) return ctx.badRequest('Invite code required');

    // 1) 校验邀请码
    const inviter = await strapi.db
      .query('plugin::users-permissions.user')
      .findOne({ where: { yaoqingMa: inviteCode } });

    if (!inviter) return ctx.badRequest('Invalid invite code');

    // 2) 构建注册参数
    const newUserData = {
      username,
      email,
      password,
      yaoqingMa: generateInviteCode(), // 手动生成邀请码
      shangji: inviter.id // 设置上级关系
    };

    // 3) 调用核心 service 创建用户
    const createdUser = await getService('user').add(newUserData);

    // 4) 生成 JWT
    const jwt = getService('jwt').issue({ id: createdUser.id });

    // 5) 输出（使用 sanitize 保证安全）
    ctx.send({
      jwt,
      user: await sanitize.contentAPI.output(createdUser)
    });
  };

  plugin.controllers.auth = original;
  return plugin;
}; 