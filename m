Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1591C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 03:26:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8459E218B0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 03:26:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8459E218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26FD56B0007; Wed, 24 Apr 2019 23:26:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21F146B0008; Wed, 24 Apr 2019 23:26:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 134406B000A; Wed, 24 Apr 2019 23:26:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CEF676B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 23:26:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f7so13409968pgi.20
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 20:26:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject
         :references:from:cc:to:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=TX92CL/CDmUqLoMD6stW+zzKukdD+1/ai2dcpyQ53II=;
        b=BZYnlLantEjbo4KnmR/jjSVElAHKQgF0KNh8vWG1GbwR8WrBeXIAmn8OUYXefS+IS6
         0Kgi8gaFCgn5py2PwLtOYPpUVqthUR84Q4yBQ6Xo1v0CYdqoRpact92d4I1uK+5t0pxR
         +jQAuRlRmGvBzp1Rm/54+814TR+Q50wm/nm0w93ngYtts16XERKyg+YpgcK5zcNHPep5
         JK41ddlD3X2OS5tve9UcCromDI5QwbcZDF/JsF64O1RmS275BwPdfg72GF7z+LlBTzyI
         NNmpY3TMHhO125nPIf5vBbrVvFhsHfi3oXEKOpKMB679FVJ8KRQs9d3hfr8GOY5eeOB5
         y3rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of qiuxishi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=qiuxishi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUSx5Qwli1WHfLH2llI/Ls5yQ3DIeEEbIguta40qjQkMdeVltt4
	maox3i0ItBNwGKfp7HXNm/A1H+CUXv5A+XsPSMdHvUzI/5EcisWPSL1BjztRNFmRMN/N5SLEx2F
	vz0IbxzT4W17sh8oaXMdQMBsIeXOpDbH7uewmcA+4QSG/YtgoSRYKKI53YqY9xPrR1w==
X-Received: by 2002:a65:6088:: with SMTP id t8mr34754002pgu.2.1556162775461;
        Wed, 24 Apr 2019 20:26:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUoTsp+1v3mwo8xtrIrhXkwqJwVA8RF9GXIKTPrw2x0/QpPjYNxoPCV6HVvM2B/YDa4jBH
X-Received: by 2002:a65:6088:: with SMTP id t8mr34753944pgu.2.1556162774640;
        Wed, 24 Apr 2019 20:26:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556162774; cv=none;
        d=google.com; s=arc-20160816;
        b=vMLjBk8UZxTz8lQWkrdQ7S1GU3XQiUVipTGWa9CzvB1gMKW0cKhrSqhU7zI3z1jh5U
         QmSkmSrvIeKwH3kEgNOxXfdNibDie5pdZoofyIa5a+CIF7uFoo0tOdSVRQYcI2hhTsPq
         m30fXRYdysiPBUYUNX7fVJnQUWrQpFxawd4EYoDn50do46GQsMggisbzzHxmTWUjAKRr
         H3i2/BYwDtx8TrDu/ygOcU5Vfh7PZUkSf/xuEXZlf30A0RoVAhuVx6wdVFbGF3Y1zq8m
         06ZqXg1Jadiwa0Zzdvu0QuRMhI/A40wZJqxArIixYmYE1dr2EKyOh7s78PQ2Mndr5POB
         b3Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:to:cc:from:references:subject;
        bh=TX92CL/CDmUqLoMD6stW+zzKukdD+1/ai2dcpyQ53II=;
        b=T3hhkCCjU1bqI8mzn97X8k7Iy6NGFtniZdw0S0moa6zMCFzy1Cd+VRirqENS3Eh2t7
         3cVIDmaJxDsqcpF9QYGl2zcRduNBNSwr4hyWCh9xYKyp7knRxT8tTDMgheP9axo1ORjR
         VZTRocsANXcIz0moz/YMIxOLJfxRwWqvmw4fA9iLO8TXh9wQWVRufBkCmYscQkBum8sn
         ywql+O1hVBT3cCV+kYMQ+bLCFhrYZ4ej736Esc1YQqm8Qbea5c+YV9dcH1uM3utgGbnV
         mcN3zal4+vHGcyofNRYls0LINPumJ8wM5h/C2Vx/bx2KnzR7Drpv08VpsGRP+CR1s1tG
         fzig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of qiuxishi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=qiuxishi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id y4si18931620pgv.154.2019.04.24.20.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 20:26:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of qiuxishi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of qiuxishi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=qiuxishi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=qiuxishi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TQAj6H9_1556162771;
Received: from 10.211.55.3(mailfrom:qiuxishi@linux.alibaba.com fp:SMTPD_---0TQAj6H9_1556162771)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 25 Apr 2019 11:26:12 +0800
Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <a0728518-a067-4f89-a8ae-3fa279f768f2.xishi.qiuxishi@alibaba-inc.com>
From: Xishi Qiu <qiuxishi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
 Dan Williams <dan.j.williams@intel.com>, dave.hansen@intel.com,
 ying.huang@intel.com, linux-mm@kvack.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>, fan.du@intel.com
Message-ID: <2158298b-d4db-671e-6cff-395e9184ecf3@linux.alibaba.com>
Date: Thu, 25 Apr 2019 11:26:11 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <a0728518-a067-4f89-a8ae-3fa279f768f2.xishi.qiuxishi@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Fan Du,

I think we should change the print in mminit_verify_zonelist too.

This patch changes the order of ZONELIST_FALLBACK, so the default numa policy can
alloc DRAM first, then PMEM, right?

Thanks,
Xishi Qiu
>     On system with heterogeneous memory, reasonable fall back lists woul be:
>     a. No fall back, stick to current running node.
>     b. Fall back to other nodes of the same type or different type
>        e.g. DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3
>     c. Fall back to other nodes of the same type only.
>        e.g. DRAM node 0 -> DRAM node 1
> 
>     a. is already in place, previous patch implement b. providing way to
>     satisfy memory request as best effort by default. And this patch of
>     writing build c. to fallback to the same node type when user specify
>     GFP_SAME_NODE_TYPE only.
> 
>     Signed-off-by: Fan Du <fan.du@intel.com>
>     ---
>      include/linux/gfp.h    |  7 +++++++
>      include/linux/mmzone.h |  1 +
>      mm/page_alloc.c        | 15 +++++++++++++++
>      3 files changed, 23 insertions(+)
> 
>     diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>     index fdab7de..ca5fdfc 100644
>     --- a/include/linux/gfp.h
>     +++ b/include/linux/gfp.h
>     @@ -44,6 +44,8 @@
>      #else
>      #define ___GFP_NOLOCKDEP 0
>      #endif
>     +#define ___GFP_SAME_NODE_TYPE 0x1000000u
>     +
>      /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>      
>      /*
>     @@ -215,6 +217,7 @@
>      
>      /* Disable lockdep for GFP context tracking */
>      #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
>     +#define __GFP_SAME_NODE_TYPE ((__force gfp_t)___GFP_SAME_NODE_TYPE)
>      
>      /* Room for N __GFP_FOO bits */
>      #define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
>     @@ -301,6 +304,8 @@
>          __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
>      #define GFP_TRANSHUGE (GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
>      
>     +#define GFP_SAME_NODE_TYPE (__GFP_SAME_NODE_TYPE)
>     +
>      /* Convert GFP flags to their corresponding migrate type */
>      #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
>      #define GFP_MOVABLE_SHIFT 3
>     @@ -438,6 +443,8 @@ static inline int gfp_zonelist(gfp_t flags)
>      #ifdef CONFIG_NUMA
>       if (unlikely(flags & __GFP_THISNODE))
>        return ZONELIST_NOFALLBACK;
>     + if (unlikely(flags & __GFP_SAME_NODE_TYPE))
>     +  return ZONELIST_FALLBACK_SAME_TYPE;
>      #endif
>       return ZONELIST_FALLBACK;
>      }
>     diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>     index 8c37e1c..2f8603e 100644
>     --- a/include/linux/mmzone.h
>     +++ b/include/linux/mmzone.h
>     @@ -583,6 +583,7 @@ static inline bool zone_intersects(struct zone *zone,
>      
>      enum {
>       ZONELIST_FALLBACK, /* zonelist with fallback */
>     + ZONELIST_FALLBACK_SAME_TYPE, /* zonelist with fallback to the same type node */
>      #ifdef CONFIG_NUMA
>       /*
>        * The NUMA zonelists are doubled because we need zonelists that
>     diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>     index a408a91..de797921 100644
>     --- a/mm/page_alloc.c
>     +++ b/mm/page_alloc.c
>     @@ -5448,6 +5448,21 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
>       }
>       zonerefs->zone = NULL;
>       zonerefs->zone_idx = 0;
>     +
>     + zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK_SAME_TYPE]._zonerefs;
>     +
>     + for (i = 0; i < nr_nodes; i++) {
>     +  int nr_zones;
>     +
>     +  pg_data_t *node = NODE_DATA(node_order[i]);
>     +
>     +  if (!is_node_same_type(node->node_id, pgdat->node_id))
>     +   continue;
>     +  nr_zones = build_zonerefs_node(node, zonerefs);
>     +  zonerefs += nr_zones;
>     + }
>     + zonerefs->zone = NULL;
>     + zonerefs->zone_idx = 0;
>      }
>      
>      /*
>     -- 
>     1.8.3.1
> 
> 

