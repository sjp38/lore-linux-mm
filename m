Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8773CC4CECF
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 04:54:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55A62214AF
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 04:54:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55A62214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A8116B0006; Mon, 16 Sep 2019 00:54:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30B296B0007; Mon, 16 Sep 2019 00:54:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21E8E6B0008; Mon, 16 Sep 2019 00:54:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0130.hostedemail.com [216.40.44.130])
	by kanga.kvack.org (Postfix) with ESMTP id 05BC66B0006
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 00:54:18 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 85E144845
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 04:54:18 +0000 (UTC)
X-FDA: 75939567396.17.milk11_5f9b916be010b
X-HE-Tag: milk11_5f9b916be010b
X-Filterd-Recvd-Size: 2493
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 04:54:16 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Sep 2019 21:54:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,492,1559545200"; 
   d="scan'208";a="190964364"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga006.jf.intel.com with ESMTP; 15 Sep 2019 21:54:12 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1i9j1g-0003jq-5a; Mon, 16 Sep 2019 12:54:12 +0800
Date: Mon, 16 Sep 2019 12:53:50 +0800
From: kbuild test robot <lkp@intel.com>
To: Pengfei Li <lpf.vector@gmail.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, vbabka@suse.cz,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, guro@fb.com,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [RFC PATCH] mm, slab_common: all_kmalloc_info[] can be static
Message-ID: <20190916045350.2buptf4exdnbxttf@48261080c7f1>
References: <20190915170809.10702-6-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190915170809.10702-6-lpf.vector@gmail.com>
X-Patchwork-Hint: ignore
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Fixes: 95f3b3d20e9b ("mm, slab_common: Make kmalloc_caches[] start at size KMALLOC_MIN_SIZE")
Signed-off-by: kbuild test robot <lkp@intel.com>
---
 slab_common.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2aed30deb0714..bf1cf4ba35f86 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1118,7 +1118,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
  * time. kmalloc_index() supports up to 2^26=64MB, so the final entry of the
  * table is kmalloc-67108864.
  */
-const struct kmalloc_info_struct all_kmalloc_info[] __initconst = {
+static const struct kmalloc_info_struct all_kmalloc_info[] __initconst = {
 	SET_KMALLOC_SIZE(       8,    8),    SET_KMALLOC_SIZE(      16,   16),
 	SET_KMALLOC_SIZE(      32,   32),    SET_KMALLOC_SIZE(      64,   64),
 #if KMALLOC_SIZE_96_EXIST == 1

