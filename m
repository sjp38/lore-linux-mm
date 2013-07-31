Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4C8556B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 03:32:01 -0400 (EDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH 0/4] memcg: fix memcg resource limit overflow issues
Date: Wed, 31 Jul 2013 15:31:21 +0800
Message-ID: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: handai.szj@taobao.com, lizefan@huawei.com, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, mhocko@suse.cz, jeff.liu@oracle.com

This issue is first discussed in:
http://marc.info/?l=linux-mm&m=136574878704295&w=2

Then a second version sent to:
http://marc.info/?l=linux-mm&m=136776855928310&w=2

We contacted Sha a month ago, she seems have no time to deal with it 
recently, but we quite need this patch. So I modified and resent it.

Qiang Huang (4):
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
