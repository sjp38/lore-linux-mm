Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C32D3C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:21:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35C882075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:21:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HtLdXNwl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35C882075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3B066B026A; Wed,  5 Jun 2019 17:21:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEC586B026B; Wed,  5 Jun 2019 17:21:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C01AA6B026C; Wed,  5 Jun 2019 17:21:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 70FFB6B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 17:21:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a21so290708edt.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 14:21:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jmqIL302FliKztrku23iEbel/vN8Om9KZr4KoJVUQBs=;
        b=dMiw4hc2XWW7cjxOIkkxP9u8CJppeoFbgCi4euscwTq1aowRw/Ea42iQViB4/a3+i+
         HjgxaCcgBvxYtaB5iULbDmP7aU0sdLawkNkEbMHJoBL1P+R6MnMLVbCIm2x5ON/f7/u9
         +QppgX5WqGyR+z8nJ9D0DkAjK3YRzaRpuEmnP/yvPHpmGbnB9pcpQYWyBFOXIsQMrzFT
         c/d7kQu3lar9FyxzInA8JEjvDPlGL9MTFmvX5dfr9jD4MP5UxO3Nl1UsUWcB2G+Ijdvm
         ihvNmNaUiBKI3romCKqBaGvFbcH79fbS/9/btJ1HrbPtz99ifcyJqyNVxhDaW5L07W6v
         z8ag==
X-Gm-Message-State: APjAAAUdMuHfhqcNGtp9wG67Dq4RmDy+h1y5DCN6ACBO9tY7uz2gi+zi
	4CpvrYWGHZEzXdm3oDfMOhkTxxskeWILUBrpkO4Z8HSaEYGGwAE1ksgAsmjcada22JYEftzdM0i
	2iDZxvJoeYqUZ6tYmVeQvIuhwlnZUk/qzVE1k8lPcVJ3dAoRhPhshF7+379dFbK+3AQ==
X-Received: by 2002:a17:906:4cc3:: with SMTP id q3mr13075177ejt.27.1559769688036;
        Wed, 05 Jun 2019 14:21:28 -0700 (PDT)
X-Received: by 2002:a17:906:4cc3:: with SMTP id q3mr13075153ejt.27.1559769687337;
        Wed, 05 Jun 2019 14:21:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559769687; cv=none;
        d=google.com; s=arc-20160816;
        b=mfIQJtyWLdDHyRRdMJ/MlBFGpuvu3Zdbh7e5RlqWvWfvaeFdIUAVQRp8OGMMydVlrz
         H7Q+oEn/vPee+1YiCBAdohSgAM+ULHezJx3knrdb0HWtq88B5SrRfNRrkSZQ8TGkyB+V
         UCcQtbKRYWAtjmdWJ6nYsYdpxB/RNRJDDm1FGtuiEHQXRMpuK3MG4EexJd5Xk9fKGdAo
         vjbDoFD5jxBssJQYdherdUI2Pd7J9VXqFOU6IvVOg4bS1ucvGnx6ajbRyikOXt/fgNKC
         xH+HKL6GJd3hZ0fncFMW/u2wRc3u2eAkRFzGyTp4u+WfHTPoSA3aMuUd0dIusuxKDYVS
         ocZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=jmqIL302FliKztrku23iEbel/vN8Om9KZr4KoJVUQBs=;
        b=h+Na/IE/6rNjt/NIrXByXRdq8qjZpEbCmcspmzMnk6Kt8F9UaK2kUBZX3duBttta5B
         rWLWyy2OdT160Zp8xbUVctlu2HBm6OPrwE3wrq/7iIltpMUewndMF6XYJn1ViNUOzFDy
         eUqhwH4Ez5sEsDIQ20lqm4D96WZZVpf2zU3hSapuzPBXKqvZ5X3tjCg+AyrJoCaOCSbz
         owa8vjmbMuz9bP65rJu8aXLcoF97w7vrUbjJTNvXndxo9yrme9PM8YE7Pro9v56TAhWZ
         b3uWerTx49D3dckWX9X5Ldq52KXwxOhnMafiLQ9l04c7TkuDomfdgzKV33KNHfN7TUtX
         wqiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HtLdXNwl;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor1455059eda.1.2019.06.05.14.21.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 14:21:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HtLdXNwl;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jmqIL302FliKztrku23iEbel/vN8Om9KZr4KoJVUQBs=;
        b=HtLdXNwlPpU1RFxmpHZq/rH78NiFyUbMRNR4XLHGl5DFaciTYXzczF+YOEaOthAltb
         LzfrkniAfXeG9XfS8k8l9WWdWJTCb5t0Qydwrx9HDSWfQxVverG9o6eBxNShll611+Xk
         D8MDiZNeQ9S8YaEkKYI92ohNxvxiKGjBgdANYmGfcUxcUcAmDq0kOuCUWCUGDd+d7T8p
         u6tdGt0M3uFblUt67ApuYvpm2psLcK1H66EYwESimtXZEx5o8tKBJ+DBxrVlRNPstQNp
         2xk+bEsv5+yigah3/6Lj+npsGt7LKO/9d2Bkh2IRQhSgPxae7KCEIl0WkMOEkno6k2FP
         1Lng==
X-Google-Smtp-Source: APXvYqxldygk3PkHMpihOlAqhwTjzhXRQF4Z9tCxVu286QjlehnozfaHCkEEtI5NYMQPFpu5SuYeWg==
X-Received: by 2002:a50:ca48:: with SMTP id e8mr45737760edi.101.1559769687081;
        Wed, 05 Jun 2019 14:21:27 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id e19sm3550413edy.36.2019.06.05.14.21.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 14:21:26 -0700 (PDT)
Date: Wed, 5 Jun 2019 21:21:25 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH v3 11/11] mm/memory_hotplug: Remove "zone" parameter from
 sparse_remove_one_section
Message-ID: <20190605212125.gwmvjjicylhp3wcz@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-12-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-12-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:52PM +0200, David Hildenbrand wrote:
>The parameter is unused, so let's drop it. Memory removal paths should
>never care about zones. This is the job of memory offlining and will
>require more refactorings.
>
>Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

>---
> include/linux/memory_hotplug.h | 2 +-
> mm/memory_hotplug.c            | 2 +-
> mm/sparse.c                    | 4 ++--
> 3 files changed, 4 insertions(+), 4 deletions(-)
>
>diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>index 2f1f87e13baa..1a4257c5f74c 100644
>--- a/include/linux/memory_hotplug.h
>+++ b/include/linux/memory_hotplug.h
>@@ -346,7 +346,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
> extern bool is_memblock_offlined(struct memory_block *mem);
> extern int sparse_add_one_section(int nid, unsigned long start_pfn,
> 				  struct vmem_altmap *altmap);
>-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>+extern void sparse_remove_one_section(struct mem_section *ms,
> 		unsigned long map_offset, struct vmem_altmap *altmap);
> extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
> 					  unsigned long pnum);
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index 82136c5b4c5f..e48ec7b9dee2 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -524,7 +524,7 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
> 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
> 	__remove_zone(zone, start_pfn);
> 
>-	sparse_remove_one_section(zone, ms, map_offset, altmap);
>+	sparse_remove_one_section(ms, map_offset, altmap);
> }
> 
> /**
>diff --git a/mm/sparse.c b/mm/sparse.c
>index d1d5e05f5b8d..1552c855d62a 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -800,8 +800,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
> 		free_map_bootmem(memmap);
> }
> 
>-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>-		unsigned long map_offset, struct vmem_altmap *altmap)
>+void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
>+			       struct vmem_altmap *altmap)
> {
> 	struct page *memmap = NULL;
> 	unsigned long *usemap = NULL;
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

