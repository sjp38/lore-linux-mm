Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E2DAC282CC
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 13:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59D972087C
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 13:33:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DlPChe98"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59D972087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E885C8E0043; Mon,  4 Feb 2019 08:33:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E37888E001C; Mon,  4 Feb 2019 08:33:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D27F98E0043; Mon,  4 Feb 2019 08:33:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCC68E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 08:33:05 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so10354030pgb.7
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 05:33:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2G6Id+7yUjSDlyENM/Qb+5JYzGtdNlR6zD4wg6ATMd0=;
        b=I6N9EQw7EXXBW67hMtuzQJ0RxqdTX2q9MaZlbUsXbyjcanCHGrOfBx1Yak8NGFCgT1
         OSXdqHtV7zeaiGxazbTo3kCJQBMJNaDKLOZTQVAou9iu7xDgLXkrLAlQ2MF2lrhPbRwx
         wFjn6ZST22K+CAEq4pDgonwLbe5Zwn1n/eVWCiVsqBB+aohB9zMkHpSVcBraK2cuFWNo
         Gx4MP6DSxa+dyQam/5mLVBZ5qAg5WYhveBfgfw6t+++JaJItbL1zd4pEc7qwhN8BREFX
         0YMv/Oo6oj2aAuPq9gESevCaf0fcJMswWij51/ZLzlAmPakuyd4NHIsh9P4UZENXaPpK
         bDng==
X-Gm-Message-State: AHQUAuaVukEr4FSoDPJNySyNfK1zsHxB6Dpy6HIiQiPgeTBJjkWgyzwt
	k47jcoaK74PvFPrdpHjRx/YdH83/KFAB/6LfA/76SXGor+PXHLg3xuqI1aVhW3m+IhMsBNZX6r4
	xp3zC+DqosDC+ZkfoUqMjKJRN05bE5rGCsfktJsoSe5sVnnyfPFIoNTjRPnY+F5+hyw==
X-Received: by 2002:a63:a452:: with SMTP id c18mr13091700pgp.204.1549287185126;
        Mon, 04 Feb 2019 05:33:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia40Vu793kTl+WgutDOBpej8QNAjcmDbYK4KM8M3L6yh8sY0Cajb9ASxKbrdgsYMjp8jD4O
X-Received: by 2002:a63:a452:: with SMTP id c18mr13091649pgp.204.1549287184302;
        Mon, 04 Feb 2019 05:33:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549287184; cv=none;
        d=google.com; s=arc-20160816;
        b=pocxpXTlXtSvyGLQzyXtyszbo4BAxByE+vkjoZ4MxuyJXpDLbTOIxPomFdAWnNODvC
         JxEgaHKjw1UvqQylHwtknsFqiJdYNwAa4Gj/S2uu3at2kVcv+/SIX30qxIT27i9aTteJ
         gUdl70TMCpNJfAAc1s+sharuVbvEriN4+Bf178jI0vRHsCxutAS5cHKhKu7ow+3SAthy
         2sZ438Rcell6Ax34qEZRck3D+wT4D8I9bL642ebWrUvUvQAI4C/6Whzfl5R+VUAvHFUD
         /oQkmjVQ/0BckDwobxnqNI78qsopORcT+kmdxdyyjmX67PrB02p5I4NXMeQT9GqQMniV
         45vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2G6Id+7yUjSDlyENM/Qb+5JYzGtdNlR6zD4wg6ATMd0=;
        b=a2h10gBYhGGvWBimr/H/drCtcBSWtxixSZ/flyJNFHuX3FbIZYx96QIG7GMrGZKsrn
         CWuTQ1eAnskeXlwAUdKYGSedVDvjLp2Kc/EpqhK+llZ+dqzlImMhTr/nRjjgs3aPKZVa
         Ktv4QypziQND832SB0biMcFghaPGFPjjKIax7Cc7Fd++jinnXMhsqB7Hq9Ch7QAy68z5
         hW3/POyijA3NRYFmrLbIKbJlo3YY4WZrbzZrLASFD53cfv838J9+4jv8AwjWVpOLtJIw
         floTPS4E5ngldkjJaFXeG71UByPmglTPZ+wYM4iMaqIUGuoawppUgfr/1AZEVvSTYMOT
         1bCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DlPChe98;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e8si73419pgc.174.2019.02.04.05.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 05:33:04 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DlPChe98;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2G6Id+7yUjSDlyENM/Qb+5JYzGtdNlR6zD4wg6ATMd0=; b=DlPChe98Mr380+TO6KbVQOpu0
	YvmsJaUplLeLHGXiyjaWiuAeBy/5o3b1I/EA9PkL8n2njwhS87EsTjwNFK6AEHaLWi/VdAnICfFG1
	w2vy3oEqA3qvRvZJT1TueMz9cufsi2TRUQcwFvwRHjEQN7M5fJH0HpYsGyTsJ3kVAvHf5XuTJsER2
	cVrZfug+e39sXOwCZBTr+6mbppbd8nN4aKIyH8imiubVCcL1WZg9I/UoIldi3PoS/i+Gt6+tCsVpA
	Ggjlffbo2id7LvtOHsU6/YDIdyXvIrwHirrrNTHTBFa2UnDrjnqvRiGRM/m+IsJz6LmMr03xjt2Wa
	L5kL8Kcfg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gqeMu-0004eR-U6; Mon, 04 Feb 2019 13:33:00 +0000
Date: Mon, 4 Feb 2019 05:33:00 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mm/vmalloc: convert vmap_lazy_nr to atomic_long_t
Message-ID: <20190204133300.GA21860@bombadil.infradead.org>
References: <20190131162452.25879-1-urezki@gmail.com>
 <20190201124528.GN11599@dhcp22.suse.cz>
 <20190204104956.vg3u4jlwsjd2k7jn@pc636>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204104956.vg3u4jlwsjd2k7jn@pc636>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 11:49:56AM +0100, Uladzislau Rezki wrote:
> On Fri, Feb 01, 2019 at 01:45:28PM +0100, Michal Hocko wrote:
> > On Thu 31-01-19 17:24:52, Uladzislau Rezki (Sony) wrote:
> > > vmap_lazy_nr variable has atomic_t type that is 4 bytes integer
> > > value on both 32 and 64 bit systems. lazy_max_pages() deals with
> > > "unsigned long" that is 8 bytes on 64 bit system, thus vmap_lazy_nr
> > > should be 8 bytes on 64 bit as well.
> > 
> > But do we really need 64b number of _pages_? I have hard time imagine
> > that we would have that many lazy pages to accumulate.
> > 
> That is more about of using the same type of variables thus the same size
> in 32/64 bit address space.
> 
> <snip>
> static void free_vmap_area_noflush(struct vmap_area *va)
> {
>     int nr_lazy;
>  
>     nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
>                                 &vmap_lazy_nr);
> ...
>     if (unlikely(nr_lazy > lazy_max_pages()))
>         try_purge_vmap_area_lazy();
> <snip>
> 
> va_end/va_start are "unsigned long" whereas atomit_t(vmap_lazy_nr) is "int". 
> The same with lazy_max_pages(), it returns "unsigned long" value.
> 
> Answering your question, in 64bit, the "vmalloc" address space is ~8589719406
> pages if PAGE_SIZE is 4096, i.e. a regular 4 byte integer is not enough to hold
> it. I agree it is hard to imagine, but it also depends on physical memory a
> system has, it has to be terabytes. I am not sure if such systems exists.

There are certainly systems with more than 16TB of memory out there.
The question is whether we want to allow individual vmaps of 16TB.
We currently have a 32TB vmap space (on x86-64), so that's one limit.
Should we restrict it further to avoid this ever wrapping past a 32-bit
limit?

