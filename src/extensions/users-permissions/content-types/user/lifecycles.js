module.exports = {
  /**
   * 注释掉自动生成邀请码，改为在注册时手动设置
   * 避免与 Strapi 内部字段冲突
   */
  // async beforeCreate(event) {
  //   const { data } = event.params;
  //   if (!data.yaoqingMa) {
  //     let code;
  //     do {
  //       code = Math.random().toString(36).substring(2, 8).toUpperCase();
  //     } while (
  //       await strapi.db.query('plugin::users-permissions.user').findOne({
  //         where: { yaoqingMa: code },
  //         select: ['id']
  //       })
  //     );
  //     data.yaoqingMa = code;
  //   }
  // }
}; 