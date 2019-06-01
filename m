Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAEFBC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6274F272D8
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="isXTkHpb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6274F272D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF7FE6B028B; Sat,  1 Jun 2019 09:20:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D81656B028D; Sat,  1 Jun 2019 09:20:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C97076B028E; Sat,  1 Jun 2019 09:20:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90E4F6B028B
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e69so6564423pgc.7
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LnO1hq39Y0iQ7Q5lCTtAjjgXCCd7xqHk1rIux3CEmes=;
        b=T3caRhVu3ibcqGRaMzrVceg00IVn3rXDJgMdUjuyDyGmEi1WU5a8p9k4rR6F95Trp5
         z7YTQF5rV7qZ29aoQIx71yhhfSXkbajNY90tFt1/iqNqOD5cKnuwAyc2Bqczx2iYDW3P
         euAvU8kZFt1kkONwBOAVcuzwMp2I3KC+wuJvfHqS+Gig3jOQGRdU8i4b569RZ3tLP/PM
         HPzJsIidFVaQrbcZgoWUydSE4THsHm931451k6Rr433hGj5aqFTLLOwyxBayNJsvGitg
         KFS8fkbxmky7mcQG2c1mu5bqm8NOqhCJOAL00lwcU4Vr1nslwgixFePASX08nBGqq+BU
         897Q==
X-Gm-Message-State: APjAAAU1qVvaOGJmD/QgFhLb9nMnN1wHpVPD/PL+hsqqe5hXfwsqqnnE
	rmwqSlCit7R4WQjrAdgDV4pKM+uf5x8zW82VJgtsn/sCx2VBTfWXE3FWTytd5QM5HADBQhtMwxc
	3i68OhiKvl1/m/QPDjggKyxJ/S/8eZcUh1XoMfKovPvkamaWCrLurls8zp0ReIxiX5Q==
X-Received: by 2002:a62:68c4:: with SMTP id d187mr17569066pfc.245.1559395241253;
        Sat, 01 Jun 2019 06:20:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxt9+ASy5iS26w5VXT1pWJbRBLXBBgtx3R4OV2JOruxtoex46sNYfBA7x6WIif5MtDexB4T
X-Received: by 2002:a62:68c4:: with SMTP id d187mr17568998pfc.245.1559395240627;
        Sat, 01 Jun 2019 06:20:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395240; cv=none;
        d=google.com; s=arc-20160816;
        b=u/WAHhkEyWWrko3H5zcsG8DGn+hKXriJmPkHS7712FJqS3x0kgz1AqQKSPdAHz4XSK
         O98ni4hHzRilEv6Z62oJzanN9Gp08grdA8kkgCtLSv2nUhI2pfdOM3VrydPV53l9jAT3
         MmNFpBt8VXB/DOTkG7h6EL8Es51Ht5DyKsSV/XhwbqLlN8yz9IK8WKQDYb0XlKmLoBnT
         FvUJD42Ou9IH5gif2OL93qPNk1Ndr8bsziEAs6XB+YOw7KWKuxVhItcJCsaciy93DG+9
         6BxxcWZnjeXATGiiNOLWFgK4capSifUWR/WjfiAQmkFPFkWDsNekj+ac0/PGej72Ij4k
         mwNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LnO1hq39Y0iQ7Q5lCTtAjjgXCCd7xqHk1rIux3CEmes=;
        b=v7hi533NK/6CItwO6vbP1NjAwLRgNgd3ECE29t+CGsxbhoAmuutBvggVK2UMCWu1dl
         qyQ9shKo+5MbVmvdlVl8rz8ONXcF643iM5Ilkss5K+Bu5gr2ZlyzWPZfVULsGKvlrqyJ
         t3dSX8Ou4H9iFlSsF2UoVL7O5We0+BMvfF3I53Zm6yOkzdaegMPGHSlTRhPMgv0sNJS1
         MN92uzjWTt5zxpi/EyjWPgBSsPsHKzM1QIn8Vrn7bqhnDqSWeSjBkDxrm8LBw191AAu4
         +hFFZr0/DBHfeB5KH6AOyflCe9uBVmsJBUOIAoY+CD169jpioOykrzreywNUYfIrKvLt
         cDGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=isXTkHpb;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m11si9812023pjl.64.2019.06.01.06.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=isXTkHpb;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 20879272DE;
	Sat,  1 Jun 2019 13:20:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395240;
	bh=U4sB3dWCPHwc1nLm/zgQjuLXCr/ooxzXR6feKSSgEDM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=isXTkHpbG4Lty0mdtDY+UH/NYfjU/GxrRPW6WAVYD4lT1OIXhxi6zPwi0ykqb3B95
	 cdPQf308lO/memHpEyK8xxfcwtxgeIjS0fsW/ZonFW5gf/9Op/vmTTh19AIRqPuUnw
	 6dube5hkRmt0iqegN3+Z8qP73tDlqF08ZEYqmCZY=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 020/173] mm/slab.c: fix an infinite loop in leaks_show()
Date: Sat,  1 Jun 2019 09:16:52 -0400
Message-Id: <20190601131934.25053-20-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131934.25053-1-sashal@kernel.org>
References: <20190601131934.25053-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 745e10146c31b1c6ed3326286704ae251b17f663 ]

"cat /proc/slab_allocators" could hang forever on SMP machines with
kmemleak or object debugging enabled due to other CPUs running do_drain()
will keep making kmemleak_object or debug_objects_cache dirty and unable
to escape the first loop in leaks_show(),

do {
	set_store_user_clean(cachep);
	drain_cpu_caches(cachep);
	...

} while (!is_store_user_clean(cachep));

For example,

do_drain
  slabs_destroy
    slab_destroy
      kmem_cache_free
        __cache_free
          ___cache_free
            kmemleak_free_recursive
              delete_object_full
                __delete_object
                  put_object
                    free_object_rcu
                      kmem_cache_free
                        cache_free_debugcheck --> dirty kmemleak_object

One approach is to check cachep->name and skip both kmemleak_object and
debug_objects_cache in leaks_show().  The other is to set store_user_clean
after drain_cpu_caches() which leaves a small window between
drain_cpu_caches() and set_store_user_clean() where per-CPU caches could
be dirty again lead to slightly wrong information has been stored but
could also speed up things significantly which sounds like a good
compromise.  For example,

 # cat /proc/slab_allocators
 0m42.778s # 1st approach
 0m0.737s  # 2nd approach

[akpm@linux-foundation.org: tweak comment]
Link: http://lkml.kernel.org/r/20190411032635.10325-1-cai@lca.pw
Fixes: d31676dfde25 ("mm/slab: alternative implementation for DEBUG_SLAB_LEAK")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index f4bbc53008f3b..932a439149cdb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4317,8 +4317,12 @@ static int leaks_show(struct seq_file *m, void *p)
 	 * whole processing.
 	 */
 	do {
-		set_store_user_clean(cachep);
 		drain_cpu_caches(cachep);
+		/*
+		 * drain_cpu_caches() could make kmemleak_object and
+		 * debug_objects_cache dirty, so reset afterwards.
+		 */
+		set_store_user_clean(cachep);
 
 		x[1] = 0;
 
-- 
2.20.1

