Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFCC6C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:06:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 915BF2082E
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:06:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KIqvX9gL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 915BF2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C1628E004D; Mon,  4 Feb 2019 13:06:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 296CB8E001C; Mon,  4 Feb 2019 13:06:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 188628E004D; Mon,  4 Feb 2019 13:06:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC618E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:06:38 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id j24-v6so114611lji.20
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:06:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tifl2fjh91CXdZBD9PbeUXjB2c6ZnYPpiuLFbU9AUnM=;
        b=FMkFvRNwyRLf55+SqgUuh09nUc6wPpimEjPLw3MtXQrYVSA5SRm5mzJ4V1bA7IPCEH
         +1P40tpGDKjAnV+K0CNK7mM1nBrEjmS6nOgyMwvbjFYnVZINUM4m0H4p3HWm6LsqTW8u
         OZZO9O6f5+GKvS6tEiSreAYjAcNipA+376XOJwKXGYdgCtEWGKtaNcfa5W1adnx1oYbL
         bI+6P6L7BYgkbb4ZFu9qtXBsO4LZo7HBHdIjOogo/40R3M45HbmjNQIpRHSL0ijUgZpy
         1tod5Zn/ZvcGhQGGkgBBn0ezBqvLLBinszrv2eOz4VVoHav9ne4HlEnFNCJHdy6irm/n
         qxdw==
X-Gm-Message-State: AHQUAuaZ7WFhRF4ToZ1QC55exgAvWX/tl39p8cFj71Qovl+nXKNK9YJU
	zs80mqWzodb5piJoLIz7/1G4SGfa2zl9Ifqu979t7rwkvwCZ2ftClAgtm14yqV6puerPRaGW2PA
	NXj6pM0cFckX9uO+D85YL3uDw5pthRJXtLonChKlQLNZjyOrMjLnrUVYRDeTJL7enTuEocauLWK
	f0Gn9wAXcVnL7ozvIYDEkKyb/s9OXCLG8Ql2qFs9fM5QV+5XxPXRCk2PWGY0lC5OWbwGggBA5Ho
	VQLf48xPmwuhippNI5sfO1K8d5CtJFPgvRDBamdx7Q6C9QT66doy44fEis5Js9SPK+I5/mSOMB0
	p6s6DLpaumttsEGpczGp/QtNE3U1CoG9H7/ot2MmT0t8EXAH19TkgcKDUn2RCQuPzcb4qIUi5S3
	o
X-Received: by 2002:a2e:91d1:: with SMTP id u17-v6mr403721ljg.160.1549303597808;
        Mon, 04 Feb 2019 10:06:37 -0800 (PST)
X-Received: by 2002:a2e:91d1:: with SMTP id u17-v6mr403678ljg.160.1549303596699;
        Mon, 04 Feb 2019 10:06:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549303596; cv=none;
        d=google.com; s=arc-20160816;
        b=JgJBACZ6BYT8vDQ4KkeXGQfI8RyDlvsfCbS1OZc4ivd5C32Ok1g964txuDOLdbfddY
         s4LXfNOHLBVU10JW0FpfOvBSr23VeZ/4DEspI4nBh7DGfF9RK1f6E9R2KyJItnhdZL7B
         ITBgB+yTgLdnBKWU4Qr4nNqPHpYyxDZDBit+0nCx800EGzOPARvlZmcY+GSV1+CjhqVK
         B4Br3vUcPhETkyO4Ez7KFAmOs2WBWW8LrDc/0njHgCBz4diUQNHIlalzHqSugMyaDlQJ
         zYuf0j1EsTbfYFs1cTMFNGTpSC6UyCJHCaT0urcs5m2ZT2kntXBzP0edXYHx8CHjlIJ0
         HLYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=tifl2fjh91CXdZBD9PbeUXjB2c6ZnYPpiuLFbU9AUnM=;
        b=GZATowrfeNVGJ6KiOLiB8xsahD5ntO8VNjdS4s36USiIUKXXsN3iKEI/AcCzjrfdSg
         kn/4IhUoY6iA0zewruUdz5P+ZT5n9+00ensPisbatnG72gcEYU0iQnpi0RRoM+ZlHspQ
         gWaXVco65S7dX8JEf/LM9qoUp2JlsiyDdQtvHf3qxSZ9sLyyOAGcrIqf/CH6jnMS2i30
         9PMUb4SnH06oCMJcs9ursx8WUm2A/AaSCnW6pS6n7yK+J270sYWzLASWJ8U69EmJaY9H
         vekM6FCaRr7SEx5kG9CjppNWfD3OuczvOmTzJeOaxxMQrnq9qsSRaHID+wqR2ZmEopmi
         hswA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KIqvX9gL;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7-v6sor9934723lji.9.2019.02.04.10.06.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 10:06:36 -0800 (PST)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KIqvX9gL;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=tifl2fjh91CXdZBD9PbeUXjB2c6ZnYPpiuLFbU9AUnM=;
        b=KIqvX9gLXtt/OXJFsfOAqj1Oxn4uJd4F0HpBDR5cn0hTtQQ1WpQqXFEZ4wCjGxqZ71
         e17Q7KISuQ0FGzUno9RhpmbgDk0tNsw1l6BJLrVC2SNMTm2PTpVH0Zd4DkyM/mn1b3AF
         4BGgQG7kJYjcHcDxuyTR/xucUCl/MUwYDqUNESnGV608itexst6QJdhmfKvjhrVfdV1g
         KLLT/2wqOzuqIMEnTecw/e9OyEe1y9Gqr/LNBF5KKRxfkqqZAVcWUUwM4B+GZKI4AGib
         rQw8xVQPr71kmg+cvH9CnT4UQArGc1eRvkLJYA7irII8XKi8tCnQwZxWzgdjnuWzQrDY
         YgwA==
X-Google-Smtp-Source: AHgI3IY01oOfs6e+TgiaoojNhBLc1KIx9SaDlHviSHa5lSL/dGFNaJHq1+fPkakrkI3x3xkAXPRb9w==
X-Received: by 2002:a2e:94ce:: with SMTP id r14-v6mr421255ljh.34.1549303596004;
        Mon, 04 Feb 2019 10:06:36 -0800 (PST)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id k3-v6sm2854434lja.8.2019.02.04.10.06.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 10:06:35 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 4 Feb 2019 19:06:26 +0100
To: Matthew Wilcox <willy@infradead.org>
Cc: Uladzislau Rezki <urezki@gmail.com>, Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mm/vmalloc: convert vmap_lazy_nr to atomic_long_t
Message-ID: <20190204180626.danletd4uh3rxnyd@pc636>
References: <20190131162452.25879-1-urezki@gmail.com>
 <20190201124528.GN11599@dhcp22.suse.cz>
 <20190204104956.vg3u4jlwsjd2k7jn@pc636>
 <20190204133300.GA21860@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204133300.GA21860@bombadil.infradead.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Matthew.

On Mon, Feb 04, 2019 at 05:33:00AM -0800, Matthew Wilcox wrote:
> On Mon, Feb 04, 2019 at 11:49:56AM +0100, Uladzislau Rezki wrote:
> > On Fri, Feb 01, 2019 at 01:45:28PM +0100, Michal Hocko wrote:
> > > On Thu 31-01-19 17:24:52, Uladzislau Rezki (Sony) wrote:
> > > > vmap_lazy_nr variable has atomic_t type that is 4 bytes integer
> > > > value on both 32 and 64 bit systems. lazy_max_pages() deals with
> > > > "unsigned long" that is 8 bytes on 64 bit system, thus vmap_lazy_nr
> > > > should be 8 bytes on 64 bit as well.
> > > 
> > > But do we really need 64b number of _pages_? I have hard time imagine
> > > that we would have that many lazy pages to accumulate.
> > > 
> > That is more about of using the same type of variables thus the same size
> > in 32/64 bit address space.
> > 
> > <snip>
> > static void free_vmap_area_noflush(struct vmap_area *va)
> > {
> >     int nr_lazy;
> >  
> >     nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
> >                                 &vmap_lazy_nr);
> > ...
> >     if (unlikely(nr_lazy > lazy_max_pages()))
> >         try_purge_vmap_area_lazy();
> > <snip>
> > 
> > va_end/va_start are "unsigned long" whereas atomit_t(vmap_lazy_nr) is "int". 
> > The same with lazy_max_pages(), it returns "unsigned long" value.
> > 
> > Answering your question, in 64bit, the "vmalloc" address space is ~8589719406
> > pages if PAGE_SIZE is 4096, i.e. a regular 4 byte integer is not enough to hold
> > it. I agree it is hard to imagine, but it also depends on physical memory a
> > system has, it has to be terabytes. I am not sure if such systems exists.
> 
> There are certainly systems with more than 16TB of memory out there.
> The question is whether we want to allow individual vmaps of 16TB.
Honestly saying, i do not know. But what i see is we are allowed to
do individual mapping as much as physical memory we have. If i do not
miss something.

>
> We currently have a 32TB vmap space (on x86-64), so that's one limit.
> Should we restrict it further to avoid this ever wrapping past a 32-bit
> limit?
We can restrict vmap space to 1 << 32 pages in 64 bit systems, but then
probably all archs have to follow that rule and patched accordingly. Apart
of that i am not sure how KASAN calculates start point for its allocation,
i mean offset within VMALLOC_START - VMALLOC_END address space. The same
regarding kernel module mapping space(if built to allocate in vmalloc space).

Also, since atomic_t is integer it can be negative, therefore we have to
use casting to "unsigned int" everywhere if deal with "vmap_lazy_nr".

Thank you.

--
Vlad Rezki

