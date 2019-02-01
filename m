Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14986C4151A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 00:43:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B900720B1F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 00:43:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="x0xly+Tr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B900720B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 508CC8E0002; Thu, 31 Jan 2019 19:43:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4927D8E0001; Thu, 31 Jan 2019 19:43:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35A308E0002; Thu, 31 Jan 2019 19:43:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 088EA8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 19:43:17 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 41so5784709qto.17
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 16:43:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Q4BkwvE66zdnu5FCXZwIH13O5GixEIcvPvJXakdd38A=;
        b=VvtIRx0U09gRTKEoQOXa8pcil8gS5DqEMAx0XNMVWLpbdyydxmDPPJk16kCv404AGW
         hYNkKGPuwakM3/5TSTsN7EUoYBJ1PUVnXvdWBUIusDGbPvazcrJsmRSn7Wata0TXZEcO
         24zArJKpLH+0FLtP6He7A0N/4Rnh4kdS7/4N2iGLWwvJ4t4HEDcYMc0CUGL8aABN7HnD
         hJhdYoUN2BheO9PKh8J3BCqEaS5C269l6ZTz8luql7K49fFeTqfZ8JzRibBPdXx+YArL
         i6elMi0ACvhHfmXkZ7ZVnB+OXbY5Yj9rjnnbdGB6ZBoz6geZWDbOk67D3VwVyxMxzx9B
         9NnQ==
X-Gm-Message-State: AJcUukdyk7y2AcBm8PnuwmWKKpOPw6UO6HT09xQktXm3Ir/GnJNn2eeL
	b9Ccs70nj3e6KBAz13drTTI34hCjZVhAhJ+RXZb+uESp+L19SP3U5fyrCi0774M01+EHkouc2+T
	ZTSv/K8f3vzVr0eGQ9wfzSfPWY6Jk38yZi/NtK5IozclEFmzZRrDwV1vQM11x9+A=
X-Received: by 2002:a0c:b3c2:: with SMTP id b2mr34560086qvf.138.1548981796705;
        Thu, 31 Jan 2019 16:43:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7YUOXU0d+dtPr5QDTNDQDCrAVTWgs9cTy32mLEYU0ZI5alCfMn40PQu7sMIf0FnFagSOpf
X-Received: by 2002:a0c:b3c2:: with SMTP id b2mr34560023qvf.138.1548981795278;
        Thu, 31 Jan 2019 16:43:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548981795; cv=none;
        d=google.com; s=arc-20160816;
        b=QDIXXILfP62ijNbqUwgNZfzuInU9YmgW/6p0IWrfaXrO7AuoNhXz7crtlnq49YRVJM
         xAGSGSk1WUAHUY/PNZDO7/wjyZwllluNnIS9MeVyy/lTYQHL0HKI+EYx1XH1RKQVLCWu
         bRwdi3ySGeuKGzqH919ZdLIR7PwxSgtnVQt1rc86ZheA3oQZaSPpchoyi35A1+8fMg2e
         g3Z8VUGHQ8gub0pmF6ry0vzsfSe/DwQIo2G4Shka2ecnkp/8Dtvf160W4/Cig4E9iiDS
         zHsdv4kkfEXIqOwtJAAVhsZxev0Wgp5ggRR9vi51tekPvqUQi30nR8KC0wDuXhtzRhws
         hUCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Q4BkwvE66zdnu5FCXZwIH13O5GixEIcvPvJXakdd38A=;
        b=quCAlXi5CDEyBNBInu0fpurCn92iK5mr/s1H1RftmKQrFJeso5f7FU4wgOqIMeyMxp
         DMLpqMOJ/qSsik43/Y4mYHIED7HPUPAS/SM3GhP5twqwu8ltX+iodWFHGaaak5S4SjqD
         bmLo7FFeJvGeczsGFJ+028QPaIfbRCIJM0kmOXNpW79POEYx31mG0HZJltHCf6pSl15l
         UHGreKitfN4Q4DAndNsCqi+7S990GpqC8deAZES7tr3iUNIwUquSl/3qJp4r59uVTb+I
         7kJ1ihCp59y6fZ9ew9coarjeY9MSIKLZXBjfLQkgUIww7KPSD1e73xvkG7c6z+0uA4yd
         iikA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=x0xly+Tr;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id e18si4307542qvl.65.2019.01.31.16.43.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 16:43:15 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=x0xly+Tr;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id AB0BC2E00;
	Thu, 31 Jan 2019 19:43:13 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Thu, 31 Jan 2019 19:43:14 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=Q4BkwvE66zdnu5FCX
	ZwIH13O5GixEIcvPvJXakdd38A=; b=x0xly+Trd1ygC3ICqRMBDE4UOu33Dr5zZ
	cidjBmZ80/5OHYBK9YnTkEWwKQTXznOZ6S0Em70fBp613Jh4HDslnV4o+3bdbTHX
	QPeBCGJOKSZ1ze9k6WNrTmjya158MLMSfc5WXy/TPaxqpL/4bxLTiqzvO14Goqbd
	LWYnNlG63aCh2rTOKhIPjRS20maACDUS8kxgrjZI2PpK/yw6ujqSTCMb9/cPAMP6
	X+ltboUnX5vUs+m2adFW+A3+03f7sCTEn4sXtwOAo80U48e2Cwuf4vncQs8mgyzi
	fUp/dKvU1o1p7Gt4BRJJbigSMzSAp3gnEPEaUuEeww4eJKMdAYqFw==
X-ME-Sender: <xms:H5ZTXMRW6UI7tpOTO79zDwTXQB-B-PjKJ8FpOg0388F5ZzR29cdbpw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeejgddviecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkffogg
    fgsedtkeertdertddtnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcu
    oehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukfhppeduvddurdeggedrvddvjedrud
    ehjeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghinheskhgvrhhnvghlrdhorhhg
    necuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:H5ZTXOD-IreE36fQLIUncAxKq-L6EPYUxLj6zqfGTtgdHoIx11_uAw>
    <xmx:H5ZTXE2yDmOzxnHnKH4NOl9r1XVjoaRpH6Eq_I9wXBhMMm43osTbZA>
    <xmx:H5ZTXEUibpXPw9-_PvrT89UlmE3D5RoNxBahzEdBRQsKjkWRJ5uKgA>
    <xmx:IZZTXM-bixUjVdSFOdeFXQ6KCtNTZqbDI-e2_whZ8MvG1XJTL28Kbg>
Received: from eros.localdomain (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id CE2EE10320;
	Thu, 31 Jan 2019 19:43:07 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Date: Fri,  1 Feb 2019 11:42:42 +1100
Message-Id: <20190201004242.7659-1-tobin@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently when displaying /proc/slabinfo if any cache names are too long
then the output columns are not aligned.  We could do something fancy to
get the maximum length of any cache name in the system or we could just
increase the hardcoded width.  Currently it is 17 characters.  Monitors
are wide these days so lets just increase it to 30 characters.

On one running kernel, with this choice of width, the increase is
sufficient to align the columns and total line width is increased from
112 to 119 characters (excluding the heading row).  Admittedly there may
be cache names in the wild which are longer than the cache names on this
machine, in which case the columns would still be unaligned.

Increase the width of the first column (cache name) in the output of
/proc/slabinfo from 17 to 30 characters.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---

This patch does not touch the heading row, and discussion of column
width excludes this row.  Please note that the second column labeled by
the heading row is now *not* above the second column.

### Before patch is applied sample output of `cat /proc/slabinfo` (max column width == 112):

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
kcopyd_job             0      0   3312    9    8 : tunables    0    0    0 : slabdata      0      0      0
dm_uevent              0      0   2632   12    8 : tunables    0    0    0 : slabdata      0      0      0
fuse_request          60     60    392   20    2 : tunables    0    0    0 : slabdata      3      3      0
fuse_inode            21     21    768   21    4 : tunables    0    0    0 : slabdata      1      1      0
kvm_async_pf          90     90    136   30    1 : tunables    0    0    0 : slabdata      3      3      0
kvm_vcpu               4      4  24192    1    8 : tunables    0    0    0 : slabdata      4      4      0
kvm_mmu_page_header    100    150    160   25    1 : tunables    0    0    0 : slabdata      6      6      0
i915_request         100    100    640   25    4 : tunables    0    0    0 : slabdata      4      4      0
i915_vma             316    336    576   28    4 : tunables    0    0    0 : slabdata     12     12      0
fat_inode_cache       22     22    728   22    4 : tunables    0    0    0 : slabdata      1      1      0
fat_cache              0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_groupinfo_4k   3780   3780    144   28    1 : tunables    0    0    0 : slabdata    135    135      0
ext4_inode_cache  255633 258480   1080   30    8 : tunables    0    0    0 : slabdata   8616   8616      0
ext4_allocation_context    128    128    128   32    1 : tunables    0    0    0 : slabdata      4      4      0
ext4_io_end          256    256     64   64    1 : tunables    0    0    0 : slabdata      4      4      0
ext4_extent_status 197111 197778     40  102    1 : tunables    0    0    0 : slabdata   1939   1939      0
mbcache              294    584     56   73    1 : tunables    0    0    0 : slabdata      8      8      0
jbd2_journal_head    364    476    120   34    1 : tunables    0    0    0 : slabdata     14     14      0
jbd2_revoke_table_s    512    512     16  256    1 : tunables    0    0    0 : slabdata      2      2      0
fscrypt_info         512   1024     32  128    1 : tunables    0    0    0 : slabdata      8      8      0
...


### With patch applied output of `cat /proc/slabinfo` (max column width == 119):

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <share>
PINGv6                              0      0   1152   14    4 : tunables    0    0    0 : slabdata      0      0      0
RAWv6                              14     14   1152   14    4 : tunables    0    0    0 : slabdata      1      1      0
UDPv6                               0      0   1280   12    4 : tunables    0    0    0 : slabdata      0      0      0
tw_sock_TCPv6                       0      0    240   17    1 : tunables    0    0    0 : slabdata      0      0      0
request_sock_TCPv6                  0      0    304   13    1 : tunables    0    0    0 : slabdata      0      0      0
TCPv6                               0      0   2304   14    8 : tunables    0    0    0 : slabdata      0      0      0
sgpool-128                          8      8   4096    8    8 : tunables    0    0    0 : slabdata      1      1      0
bfq_io_cq                           0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
bfq_queue                           0      0    464   17    2 : tunables    0    0    0 : slabdata      0      0      0
mqueue_inode_cache                  9      9    896    9    2 : tunables    0    0    0 : slabdata      1      1      0
dnotify_struct                      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
posix_timers_cache                  0      0    240   17    1 : tunables    0    0    0 : slabdata      0      0      0
UNIX                                0      0   1024    8    2 : tunables    0    0    0 : slabdata      0      0      0
ip4-frags                           0      0    208   19    1 : tunables    0    0    0 : slabdata      0      0      0
tcp_bind_bucket                     0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
PING                                0      0    960    8    2 : tunables    0    0    0 : slabdata      0      0      0
RAW                                 8      8    960    8    2 : tunables    0    0    0 : slabdata      1      1      0
tw_sock_TCP                         0      0    240   17    1 : tunables    0    0    0 : slabdata      0      0      0
request_sock_TCP                    0      0    304   13    1 : tunables    0    0    0 : slabdata      0      0      0
TCP                                 0      0   2176   15    8 : tunables    0    0    0 : slabdata      0      0      0
hugetlbfs_inode_cache              13     13    616   13    2 : tunables    0    0    0 : slabdata      1      1      0
dquot                               0      0    256   16    1 : tunables    0    0    0 : slabdata      0      0      0
eventpoll_pwq                       0      0     72   56    1 : tunables    0    0    0 : slabdata      0      0      0
dax_cache                          10     10    768   10    2 : tunables    0    0    0 : slabdata      1      1      0
request_queue                       0      0   2056   15    8 : tunables    0    0    0 : slabdata      0      0      0
biovec-max                          8      8   8192    4    8 : tunables    0    0    0 : slabdata      2      2      0
biovec-128                          8      8   2048    8    4 : tunables    0    0    0 : slabdata      1      1      0
biovec-64                           8      8   1024    8    2 : tunables    0    0    0 : slabdata      1      1      0
user_namespace                      8      8    512    8    1 : tunables    0    0    0 : slabdata      1      1      0
uid_cache                          21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
dmaengine-unmap-2                  64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
sock_inode_cache                   24     24    640   12    2 : tunables    0    0    0 : slabdata      2      2      0
skbuff_fclone_cache                 0      0    448    9    1 : tunables    0    0    0 : slabdata      0      0      0
skbuff_head_cache                  16     16    256   16    1 : tunables    0    0    0 : slabdata      1      1      0
file_lock_cache                     0      0    216   18    1 : tunables    0    0    0 : slabdata      0      0      0
net_namespace                       0      0   3392    9    8 : tunables    0    0    0 : slabdata      0      0      0


 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 81732d05e74a..a339f1361164 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1365,7 +1365,7 @@ static void cache_show(struct kmem_cache *s, struct seq_file *m)
 
 	memcg_accumulate_slabinfo(s, &sinfo);
 
-	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
+	seq_printf(m, "%-30s %6lu %6lu %6u %4u %4d",
 		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
 		   sinfo.objects_per_slab, (1 << sinfo.cache_order));
 
-- 
2.20.1

