Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0530AC46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 21:20:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DD7A20449
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 21:20:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="a7e5d7hV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DD7A20449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 032B56B0003; Fri,  5 Jul 2019 17:20:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F261A8E0003; Fri,  5 Jul 2019 17:20:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DED138E0001; Fri,  5 Jul 2019 17:20:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5B676B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 17:20:09 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s21so27343plr.2
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 14:20:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ngjHBZ4GCai44SJftPG33EG1j1VxsanxlKBvzKkucPA=;
        b=thOKYVckkKOi3ofk0Vtu9GZrj2D8MHOoJ6J+nRXFvdiGsjMI5ReOES68i9fy3WjQ57
         AdIb+HvYItHNMVZcOnshdcOr6JHw3GKMFTl6s+A1Y+zdyDwtOV7Dn2i3NOKA8KOKhx7H
         Ez6qh10XnAOe+KINlRZrbx3FZScnOE04jquaLkTdHiHdp8NuqG5isDD2f3CxNRUpdsK/
         +5mpjDPJ3ZnEyxNnqrbjCHhMUz9eRLtTcRVozZBMsr54p9S1PYLzDEqRT0VApMBkkjsx
         6wP1NXNRhGY19h2qjN3BeK8RIQg9ONDGR1kyRnCpPt4kXuCj7Am0fcwsBa8sw2U9SRUc
         FXhw==
X-Gm-Message-State: APjAAAW/DrF9D1OanPS5fyz/Cl9m43KuMC8jiwtAUnvzNnHDh2K6ApTk
	r/yDZ/GyFpe5ZAK1sgvc4lsXDJWev1NdXTcSUd5bWJG3NBYnrVywbrAp79wJsr6LLEUuvu9oSLi
	bQ9n5Dvs3H9mR+F2rae2ltbOuUUfP36FiXFPXPsdeIiKar9HyI6rPyC+LzbuPFD7epA==
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr237739pje.33.1562361609182;
        Fri, 05 Jul 2019 14:20:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybMXZ3CwccC22oYvD20dPDsfeiWk0WizRHReCQ2HOKyuu7+oLJQLk+MYvxvowsqUNoen2q
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr237675pje.33.1562361608316;
        Fri, 05 Jul 2019 14:20:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562361608; cv=none;
        d=google.com; s=arc-20160816;
        b=WfMud4LjiECnEPtson43Jaqpl1+cXsQ8EHWT++/eCinKSujMzRfmPCu0w6cJ9jVSe0
         MnI5d9uLtd1AZyBUofGAKTygRXO0+hIHKJmLnnW+9PLCb5pVpByV6WP3z3Cn33MZW/6H
         4waKzGu8U1Or40O/GWVlo0kqzh1BqH+4WQa2DqtUalaknfsHhHQK/cmFFbhY9PWDSw88
         iufRdiFiKeydx/eSI03SIvTayPsjn5slMBS1trLozsMjytc2bV1tl65JrTJngkqeQGKA
         vMAGwVJXIcpsMBWGdmlXI0ZbenlPmHonzU7F+zTsnUEOVVdaf0o/7FPHhls6bdIm1LUq
         suVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ngjHBZ4GCai44SJftPG33EG1j1VxsanxlKBvzKkucPA=;
        b=xIFprXCdgthvSjQoriwOe9uhXVcHcbrg7ybfTUZ9naGkUzSefG3aJcl+pO3SNByVDx
         e2SyHnYcT5xqfkIyrldEXz37lpPV4iOuZUC7r8yZxmmSfy5nSvIHKWSz8EJGJe2KOdaY
         RVKNZFk0d6h0xPpTG81aXGPC9cvtXy7YFkmMFZcW1DLGohPAomVDqQ3QPlnomAO3AdyI
         qWDXYsjwOKb6th2guOm8I0hXIADOaq+ZR/YrmK/MQGfKZeZtROjtOxK9Fx9E26Tu0Chl
         WZ8pVBzB5N6niwx0zvwFdN3R7cGxM/BMuwaTcJWVormIfGT3VXnyDAgdlfxYCAFAppf7
         ED3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a7e5d7hV;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y12si10289046pge.187.2019.07.05.14.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 14:20:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a7e5d7hV;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9DCE820449;
	Fri,  5 Jul 2019 21:20:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562361607;
	bh=KIgjG5lcpOR/w0uxRUmdQrOw3crLzVU61YDbM5cIi4g=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=a7e5d7hVie82TC2PiWxGxshF3twSUHjZ0aDo9h4ANmRfWXh6QaYidj5ZKrl7Ozc39
	 LJW+b22YyG0UJpj/MHYJckGw7LZkEB1mqEpk9eIUjQGMExHegCD+cFKyMQ9f9o9LNY
	 LAxJFdAPKNoR3TlbzZ/Fa9o2Mt929QFA7ETAwUNs=
Date: Fri, 5 Jul 2019 14:20:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, kbuild-all@01.org, Linux Memory
 Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 12342/12641] mm/vmscan.c:205:7: error:
 implicit declaration of function 'memcg_expand_shrinker_maps'; did you mean
 'memcg_set_shrinker_bit'?
Message-Id: <20190705142007.524daa9b5217f12c48e6ab65@linux-foundation.org>
In-Reply-To: <201907052120.OGYPhvno%lkp@intel.com>
References: <201907052120.OGYPhvno%lkp@intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jul 2019 21:09:24 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   22c45ec32b4a9fa8c48ef4f5bf9b189b307aae12
> commit: 8236f517d69e2217f5200d7f700e8b18b01c94c8 [12342/12641] mm: shrinker: make shrinker not depend on memcg kmem
> config: x86_64-randconfig-s2-07051907 (attached as .config)
> compiler: gcc-7 (Debian 7.4.0-9) 7.4.0
> reproduce:
>         git checkout 8236f517d69e2217f5200d7f700e8b18b01c94c8
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All error/warnings (new ones prefixed by >>):
> 
>    mm/vmscan.c: In function 'prealloc_memcg_shrinker':
> >> mm/vmscan.c:205:7: error: implicit declaration of function 'memcg_expand_shrinker_maps'; did you mean 'memcg_set_shrinker_bit'? [-Werror=implicit-function-declaration]
>       if (memcg_expand_shrinker_maps(id)) {
>           ^~~~~~~~~~~~~~~~~~~~~~~~~~
>           memcg_set_shrinker_bit
>    In file included from include/linux/rbtree.h:22:0,
>                     from include/linux/mm_types.h:10,
>                     from include/linux/mmzone.h:21,
>                     from include/linux/gfp.h:6,
>                     from include/linux/mm.h:10,
>                     from mm/vmscan.c:17:
>    mm/vmscan.c: In function 'shrink_slab_memcg':
> >> mm/vmscan.c:593:54: error: 'struct mem_cgroup_per_node' has no member named 'shrinker_map'

This?

--- a/include/linux/memcontrol.h~mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix
+++ a/include/linux/memcontrol.h
@@ -128,7 +128,7 @@ struct mem_cgroup_per_node {
 
 	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	struct memcg_shrinker_map __rcu	*shrinker_map;
 #endif
 	struct rb_node		tree_node;	/* RB tree node */
@@ -1272,6 +1272,7 @@ static inline bool mem_cgroup_under_sock
 
 struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
 void memcg_kmem_put_cache(struct kmem_cache *cachep);
+extern int memcg_expand_shrinker_maps(int new_id);
 
 #ifdef CONFIG_MEMCG_KMEM
 int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
@@ -1339,8 +1340,6 @@ static inline int memcg_cache_id(struct
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
-extern int memcg_expand_shrinker_maps(int new_id);
-
 extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
 				   int nid, int shrinker_id);
 #else
_

