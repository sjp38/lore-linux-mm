Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 63A7A6B0036
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 23:26:11 -0400 (EDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH v2 0/4] memcg: fix memcg resource limit overflow issues
Date: Fri, 2 Aug 2013 11:25:29 +0800
Message-ID: <1375413933-10732-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, lizefan@huawei.com, handai.szj@taobao.com, handai.szj@gmail.com, jeff.liu@oracle.com, nishimura@mxp.nes.nec.co.jp, cgroups@vger.kernel.org, linux-mm@kvack.org

This issue is first discussed in:
http://marc.info/?l=linux-mm&m=136574878704295&w=2

Then a second version sent to:
http://marc.info/?l=linux-mm&m=136776855928310&w=2

We contacted Sha a month ago, she seems have no time to deal with it 
recently, but we quite need this patch. So I modified and resent it.

Changes from v1:
* Added From: Sha Zhengju <handai.szj@taobao.com>
  (Sorry for the omission in the first version)
* Added Acked-by and Reviewed-by from Michal

Sha Zhengju (4):
  memcg: correct RESOURCE_MAX to ULLONG_MAX
  memcg: rename RESOURCE_MAX to RES_COUNTER_MAX
  memcg: avoid overflow caused by PAGE_ALIGN
  memcg: reduce function dereference

 include/linux/res_counter.h |  2 +-
 kernel/res_counter.c        | 25 ++++++++++++++++---------
 mm/memcontrol.c             |  4 ++--
 net/ipv4/tcp_memcontrol.c   | 10 +++++-----
 4 files changed, 24 insertions(+), 17 deletions(-)

-- 
1.8.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
