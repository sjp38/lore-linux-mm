Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD6F2C742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:42:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F191208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:42:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zG/bEdWt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F191208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3A3E8E0107; Thu, 11 Jul 2019 19:42:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D10D38E00DB; Thu, 11 Jul 2019 19:42:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C27108E0107; Thu, 11 Jul 2019 19:42:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F10E8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 19:42:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n7so4532512pgr.12
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:42:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6OsK1+tTT01cojrSFWmvK3T2hJstk/qryi9H3Co28FM=;
        b=U6Xhdlw57EpgMYSoKmNnIEyonBXpYJ+q7nKa87jlE+fTL4cgdLPNeTyadvRDpJ+FKz
         mK2drCbmtgI5mA/JaUUMAm7RkSNAgb3rs78tIFpnWCiVbrLWYI3Aw3Cvk7c4KuKU1RYS
         j1Ty81z4H6wEX29vgadmkFxe8IQxYZpKXT/z5VhtuoH7EpxCPRAiNRcAVVuD+WPpGAVU
         v12MIQ05/N1xYMBMXLxPZjrDdjuGNolGhJ1MxLpFa9xr5JwEbd0LVJUnwRcxgUNGM2eg
         og+r/YdVyinT1qxiLU9COFl7XQEDMUT0d7os0/8h7pnBg7L/IhrzMz3RoD+TjmZf1QQ+
         n9Kw==
X-Gm-Message-State: APjAAAVu7YKfwo9AGfHVQrKahz8xWWVniGVypTTAGUrY/92t9hswvwyt
	M5tISvQsRLWkeWnon3W+mSH0mcgHDGNgH4EIj6pFmm/tP7GDjNDkKiQa9xKoTQh8bhbhVm16vWo
	6ycPIPQOQ6RvMziAwZNeoCyBRlTxmsLwKnnp6hWsoy/7/MjWLEo8FlgAsy9Ya1x57pw==
X-Received: by 2002:a63:5920:: with SMTP id n32mr6907668pgb.352.1562888538027;
        Thu, 11 Jul 2019 16:42:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIoUGttzno7IwTPznjKRmawHj4yKXIwYSTtl/OyToxLB/6no+0yfbKnuKTS7Fv1PG+4rq5
X-Received: by 2002:a63:5920:: with SMTP id n32mr6907607pgb.352.1562888537209;
        Thu, 11 Jul 2019 16:42:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562888537; cv=none;
        d=google.com; s=arc-20160816;
        b=C6Fn5hJT6CWCh3gPn/IzYQbXtgl/bgxYVPNey/SXAfU7xVEQr1PnsUICFMTM5otDW9
         LMZhcFrrwMZZJn2/WKL84J7IOTfS/0yXWlyNI3ffAQbgb/b4psEtelm3MLcM1HLMcucm
         EF8YbVewIeZSK051wgghg5sg3jMBgnud0UupPtVUkAid3MPHu/SrgRQKDuInu0sexu4M
         LyDJBvQgu/l8TQqFi9YRSw+pTWObUSHOjoTY8JG5iwDPqJ+Zd56xfN7K+A6o0W3LTetk
         2l1Xo4oT3p+1sZqWja4XeE8ZaqCH8gc6hY0tPXKhhktqBhCuH0CtnL6M/gxyZM50dZf8
         qznQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6OsK1+tTT01cojrSFWmvK3T2hJstk/qryi9H3Co28FM=;
        b=x5hUR3D6PVJTZPp+FzOIRjIve5macrVPLZ/aeGSjtA34ysvfn+9RyC6f3MDDcC72RD
         K6eijKFfkXtoG0qf4dstp9TX+n+M+oZkY7jIrj27J0EV+zSo27nT9g0wwzcL9sSaq1I5
         zCbc5dZAV0bQasFtUtl/JLL1GCGTikwEefskc5qIq5PMRHE6U4cY4/BkV77z0Hz1E9Hp
         1fra/oscJ8n/g97yfNptV68Tr7nc3dIwVaBPaPU7McOALmbk64xQat+/dZu+10AUTCGm
         Nd2DbweBDjUUklU/1JoVU0aCu9FtRBNgJm9sDXDvk1pxZP0YwshqF1GWu7rYI/92CuZe
         UYfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="zG/bEdWt";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 136si6650457pgg.354.2019.07.11.16.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 16:42:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="zG/bEdWt";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 65885208E4;
	Thu, 11 Jul 2019 23:42:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562888536;
	bh=ngExoqczhKhQdCoEyBgx6czt7nOGVdrKVKtda4vlUjI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=zG/bEdWt0VviT/w9S2oCSmCi8shBBIUIW2mpB5JbvPHZgMu1i2LpMw56BjSOczGHk
	 xeyBwNOZEKYDtEDUmr5H9cxsObDs3gWAzLTGxA0SeyzLGe2R3A7dUy/A819+CZX632
	 uBflVqYme2U5vfnfTB/ymCWTQGd++jdMxq/Qee0o=
Date: Thu, 11 Jul 2019 16:42:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko
 <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Yafang Shao
 <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/memcontrol: keep local VM counters in sync with
 the hierarchical ones
Message-Id: <20190711164215.7e8fdcf635ac29f2d2572438@linux-foundation.org>
In-Reply-To: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
References: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2019 09:32:59 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:

> After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> the local VM counters is not in sync with the hierarchical ones.
> 
> Bellow is one example in a leaf memcg on my server (with 8 CPUs),
> 	inactive_file 3567570944
> 	total_inactive_file 3568029696
> We can find that the deviation is very great, that is because the 'val' in
> __mod_memcg_state() is in pages while the effective value in
> memcg_stat_show() is in bytes.
> So the maximum of this deviation between local VM stats and total VM
> stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> great value.
> 
> We should keep the local VM stats in sync with the total stats.
> In order to keep this behavior the same across counters, this patch updates
> __mod_lruvec_state() and __count_memcg_events() as well.

hm.

So the local counters are presently more accurate than the hierarchical
ones because the hierarchical counters use batching.  And the proposal
is to make the local counters less accurate so that the inaccuracies
will match.

It is a bit counter intuitive to hear than worsened accuracy is a good
thing!  We're told that the difference may be "unacceptably great" but
we aren't told why.  Some additional information to support this
surprising assertion would be useful, please.  What are the use-cases
which are harmed by this difference and how are they harmed?

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -691,12 +691,15 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
>  	if (mem_cgroup_disabled())
>  		return;
>  
> -	__this_cpu_add(memcg->vmstats_local->stat[idx], val);
> -
>  	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
>  	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
>  		struct mem_cgroup *mi;
>  
> +		/*
> +		 * Batch local counters to keep them in sync with
> +		 * the hierarchical ones.
> +		 */
> +		__this_cpu_add(memcg->vmstats_local->stat[idx], x);

Given that we are no longer batching updates to the local counters, I
wonder if it is still necessary to accumulate the counters on a per-cpu
basis.  ie, can we now do

		atomic_long_add(memcg->vmstats_local->stat[idx], x);

and remove the loop in memcg_events_local()?


