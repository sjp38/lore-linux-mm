Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC3D6B0309
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 08:47:09 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id h10so10569509pgv.20
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 05:47:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33-v6si8072411ply.121.2018.11.15.05.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Nov 2018 05:47:08 -0800 (PST)
Date: Thu, 15 Nov 2018 05:47:06 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/1] vmalloc: add test driver to analyse vmalloc
 allocator
Message-ID: <20181115134706.GC19286@bombadil.infradead.org>
References: <20181113151629.14826-1-urezki@gmail.com>
 <20181113151629.14826-2-urezki@gmail.com>
 <20181113141046.f62f5bd88d4ebc663b0ac100@linux-foundation.org>
 <20181114151737.GA23419@dhcp22.suse.cz>
 <20181114150053.c3fe42507923322a0a10ae1c@linux-foundation.org>
 <20181115083957.GE23831@dhcp22.suse.cz>
 <20181115084642.GB19286@bombadil.infradead.org>
 <20181115125750.GS23831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115125750.GS23831@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Nov 15, 2018 at 01:57:50PM +0100, Michal Hocko wrote:
> On Thu 15-11-18 00:46:42, Matthew Wilcox wrote:
> > How about adding
> > 
> > #ifdef CONFIG_VMALLOC_TEST
> > int run_internal_vmalloc_tests(void)
> > {
> > ...
> > }
> > EXPORT_SYMBOL_GPL(run_internal_vmalloc_tests);
> > #endif
> > 
> > to vmalloc.c?  That would also allow calling functions which are marked
> > as static, not just functions which aren't exported to modules.
> 
> Yes that would be easier but do we want to pollute the normal code with
> testing? This looks messy to me.

I don't think it's necessarily the worst thing in the world if random
people browsing the file are forced to read test-cases ;-)

There's certainly a spectrum of possibilities here, one end being to
basically just re-export static functions, and the other end putting
every vmalloc test into vmalloc.c.  vmalloc.c is pretty big at 70kB, but
on the other hand, it's the 18th largest file in mm/ (can you believe
page_alloc.c is 230kB?!)
