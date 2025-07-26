'use strict';

/**
 * invite-record service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::invite-record.invite-record', ({ strapi }) => ({
  // 获取用户的邀请人
  async getInviter(userId) {
    const inviteRecord = await strapi.db.query('api::invite-record.invite-record').findOne({
      where: { invitee: userId },
      populate: ['inviter']
    });
    return inviteRecord?.inviter || null;
  },

  // 获取用户邀请的所有人
  async getInvitees(userId) {
    const inviteRecords = await strapi.db.query('api::invite-record.invite-record').findMany({
      where: { inviter: userId },
      populate: ['invitee']
    });
    return inviteRecords.map(record => record.invitee);
  },

  // 获取邀请记录统计
  async getInviteStats(userId) {
    const inviteCount = await strapi.db.query('api::invite-record.invite-record').count({
      where: { inviter: userId }
    });
    return { inviteCount };
  }
})); 