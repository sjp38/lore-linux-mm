Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3903C3A5A3
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 00:39:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93734217F5
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 00:39:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93734217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18B046B0005; Tue, 27 Aug 2019 20:39:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13C9A6B0008; Tue, 27 Aug 2019 20:39:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 002BA6B000A; Tue, 27 Aug 2019 20:39:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0065.hostedemail.com [216.40.44.65])
	by kanga.kvack.org (Postfix) with ESMTP id CCCBE6B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 20:39:29 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6FDC88E4A
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 00:39:29 +0000 (UTC)
X-FDA: 75869978058.22.bear63_6fe32b0fd9a4e
X-HE-Tag: bear63_6fe32b0fd9a4e
X-Filterd-Recvd-Size: 2699
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 00:39:28 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Aug 2019 17:39:27 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,439,1559545200"; 
   d="scan'208";a="381112530"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga006.fm.intel.com with ESMTP; 27 Aug 2019 17:39:25 -0700
Date: Wed, 28 Aug 2019 08:39:03 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	David Hildenbrand <david@redhat.com>,
	Wei Yang <richardw.yang@linux.intel.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm: Don't manually decrement num_poisoned_pages
Message-ID: <20190828003903.GB15462@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190827053656.32191-1-alastair@au1.ibm.com>
 <20190827053656.32191-2-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827053656.32191-2-alastair@au1.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 03:36:54PM +1000, Alastair D'Silva wrote:
>From: Alastair D'Silva <alastair@d-silva.org>
>
>Use the function written to do it instead.
>
>Signed-off-by: Alastair D'Silva <alastair@d-silva.org>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

>---
> mm/sparse.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>
>diff --git a/mm/sparse.c b/mm/sparse.c
>index 72f010d9bff5..e41917a7e844 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -11,6 +11,8 @@
> #include <linux/export.h>
> #include <linux/spinlock.h>
> #include <linux/vmalloc.h>
>+#include <linux/swap.h>
>+#include <linux/swapops.h>
> 
> #include "internal.h"
> #include <asm/dma.h>
>@@ -898,7 +900,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> 
> 	for (i = 0; i < nr_pages; i++) {
> 		if (PageHWPoison(&memmap[i])) {
>-			atomic_long_sub(1, &num_poisoned_pages);
>+			num_poisoned_pages_dec();
> 			ClearPageHWPoison(&memmap[i]);
> 		}
> 	}
>-- 
>2.21.0

-- 
Wei Yang
Help you, Help me

