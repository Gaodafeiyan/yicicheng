'use strict';

/**
 * invite-record service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::invite-record.invite-record', ({ strapi }) => ({
  // 获取用户的邀请人
  async getInviter(userId) {
    const inviteRecord = await strapi.db.query('api::invite-record.invite-record').findOne({
      where: { invitee_user: userId },
      populate: ['inviter_user']
    });
    return inviteRecord?.inviter_user || null;
  },

  // 获取用户邀请的所有人
  async getInvitees(userId) {
    const inviteRecords = await strapi.db.query('api::invite-record.invite-record').findMany({
      where: { inviter_user: userId },
      populate: ['invitee_user']
    });
    return inviteRecords.map(record => record.invitee_user);
  },

  // 获取邀请记录统计
  async getInviteStats(userId) {
    const inviteCount = await strapi.db.query('api::invite-record.invite-record').count({
      where: { inviter_user: userId }
    });
    return { inviteCount };
  }
})); 