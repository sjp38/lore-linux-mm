Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 54DC46B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 07:27:59 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so1593268pab.10
        for <linux-mm@kvack.org>; Wed, 14 May 2014 04:27:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id oh10si807258pbb.427.2014.05.14.04.27.58
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 04:27:58 -0700 (PDT)
Date: Wed, 14 May 2014 19:26:55 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 449/499] lib/test_bpf.c:1401:16: sparse: symbol
 'populate_skb' was not declared. Should it be static?
Message-ID: <537352ff.YeKAAIraVMbFPDYy%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_537352ff.rYB1KClYSjRKOocQghAYusKltAG6k07thMly1/F7QjSNT0eb"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, mmotm auto import <mm-commits@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_537352ff.rYB1KClYSjRKOocQghAYusKltAG6k07thMly1/F7QjSNT0eb
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   1055821ba3c83218cbba4481f8349e3326cdaa32
commit: 802c295a15874b0287efd0bdeb1b3ebbacd4368b [449/499] lib/test_bpf.c: don't use gcc union shortcut
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   lib/test_bpf.c:87:17: sparse: advancing past deep designator
   lib/test_bpf.c:99:17: sparse: advancing past deep designator
   lib/test_bpf.c:114:17: sparse: advancing past deep designator
   lib/test_bpf.c:132:17: sparse: advancing past deep designator
   lib/test_bpf.c:148:17: sparse: advancing past deep designator
   lib/test_bpf.c:159:17: sparse: advancing past deep designator
   lib/test_bpf.c:169:17: sparse: advancing past deep designator
   lib/test_bpf.c:182:17: sparse: advancing past deep designator
   lib/test_bpf.c:196:17: sparse: advancing past deep designator
   lib/test_bpf.c:209:17: sparse: advancing past deep designator
   lib/test_bpf.c:223:17: sparse: advancing past deep designator
   lib/test_bpf.c:244:17: sparse: advancing past deep designator
   lib/test_bpf.c:255:17: sparse: advancing past deep designator
   lib/test_bpf.c:266:17: sparse: advancing past deep designator
   lib/test_bpf.c:277:17: sparse: advancing past deep designator
   lib/test_bpf.c:296:17: sparse: advancing past deep designator
   lib/test_bpf.c:307:17: sparse: advancing past deep designator
   lib/test_bpf.c:321:17: sparse: advancing past deep designator
   lib/test_bpf.c:335:17: sparse: advancing past deep designator
   lib/test_bpf.c:346:17: sparse: advancing past deep designator
   lib/test_bpf.c:361:17: sparse: advancing past deep designator
   lib/test_bpf.c:375:17: sparse: advancing past deep designator
   lib/test_bpf.c:409:17: sparse: advancing past deep designator
   lib/test_bpf.c:428:17: sparse: advancing past deep designator
   lib/test_bpf.c:449:17: sparse: advancing past deep designator
   lib/test_bpf.c:471:17: sparse: advancing past deep designator
   lib/test_bpf.c:484:17: sparse: advancing past deep designator
   lib/test_bpf.c:497:17: sparse: advancing past deep designator
   lib/test_bpf.c:516:17: sparse: advancing past deep designator
   lib/test_bpf.c:548:17: sparse: advancing past deep designator
   lib/test_bpf.c:580:17: sparse: advancing past deep designator
   lib/test_bpf.c:638:17: sparse: advancing past deep designator
   lib/test_bpf.c:657:17: sparse: advancing past deep designator
   lib/test_bpf.c:673:17: sparse: advancing past deep designator
   lib/test_bpf.c:689:17: sparse: advancing past deep designator
   lib/test_bpf.c:706:17: sparse: advancing past deep designator
   lib/test_bpf.c:723:17: sparse: advancing past deep designator
   lib/test_bpf.c:885:17: sparse: advancing past deep designator
   lib/test_bpf.c:1031:17: sparse: advancing past deep designator
   lib/test_bpf.c:1164:17: sparse: advancing past deep designator
   lib/test_bpf.c:1230:17: sparse: advancing past deep designator
   lib/test_bpf.c:1292:17: sparse: advancing past deep designator
   lib/test_bpf.c:1312:17: sparse: advancing past deep designator
   lib/test_bpf.c:1329:17: sparse: advancing past deep designator
   lib/test_bpf.c:1342:17: sparse: advancing past deep designator
   lib/test_bpf.c:1351:17: sparse: advancing past deep designator
   lib/test_bpf.c:1361:17: sparse: advancing past deep designator
   lib/test_bpf.c:1372:17: sparse: advancing past deep designator
   lib/test_bpf.c:1382:17: sparse: advancing past deep designator
>> lib/test_bpf.c:1401:16: sparse: symbol 'populate_skb' was not declared. Should it be static?
>> lib/test_bpf.c:1481:30: sparse: incorrect type in assignment (different address spaces)
   lib/test_bpf.c:1481:30:    expected struct sock_filter [noderef] <asn:1>*filter
   lib/test_bpf.c:1481:30:    got struct sock_filter *<noident>
>> lib/test_bpf.c:1482:45: sparse: incorrect type in argument 1 (different address spaces)
   lib/test_bpf.c:1482:45:    expected struct sock_filter *[assigned] fp
   lib/test_bpf.c:1482:45:    got struct sock_filter [noderef] <asn:1>*filter

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_537352ff.rYB1KClYSjRKOocQghAYusKltAG6k07thMly1/F7QjSNT0eb
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-802c295a15874b0287efd0bdeb1b3ebbacd4368b.diff"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH mmotm] lib/test_bpf.c: populate_skb() can be static
TO: Andrew Morton <akpm@linux-foundation.org>
CC: Linux Memory Management List <linux-mm@kvack.org>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: linux-kernel@vger.kernel.org 

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Linux Memory Management List <linux-mm@kvack.org>
CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 test_bpf.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 0fa58d2..f5a630a 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1398,7 +1398,7 @@ static int get_length(struct sock_filter *fp)
 }
 
 struct net_device dev;
-struct sk_buff *populate_skb(char *buf, int size)
+static struct sk_buff *populate_skb(char *buf, int size)
 {
 	struct sk_buff *skb;
 

--=_537352ff.rYB1KClYSjRKOocQghAYusKltAG6k07thMly1/F7QjSNT0eb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
