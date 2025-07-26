module.exports = {
  /**
   * beforeCreate = 仅注册时触发；
   * 生成 6 位大写字母数字组合，不重复。
   */
  async beforeCreate(event) {
    const { data } = event.params;
    if (!data.inviteCode) {
      let code;
      do {
        code = Math.random().toString(36).substring(2, 8).toUpperCase();
      } while (
        await strapi.db.query('plugin::users-permissions.user').findOne({
          where: { inviteCode: code },
          select: ['id']
        })
      );
      data.inviteCode = code;
    }
  }
}; 