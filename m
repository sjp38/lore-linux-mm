Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECC8C6B0006
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:46:44 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id d11-v6so13926886plo.17
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:46:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x23si16739811pgj.247.2018.11.15.00.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Nov 2018 00:46:43 -0800 (PST)
Date: Thu, 15 Nov 2018 00:46:42 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/1] vmalloc: add test driver to analyse vmalloc
 allocator
Message-ID: <20181115084642.GB19286@bombadil.infradead.org>
References: <20181113151629.14826-1-urezki@gmail.com>
 <20181113151629.14826-2-urezki@gmail.com>
 <20181113141046.f62f5bd88d4ebc663b0ac100@linux-foundation.org>
 <20181114151737.GA23419@dhcp22.suse.cz>
 <20181114150053.c3fe42507923322a0a10ae1c@linux-foundation.org>
 <20181115083957.GE23831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115083957.GE23831@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Nov 15, 2018 at 09:39:57AM +0100, Michal Hocko wrote:
> On Wed 14-11-18 15:00:53, Andrew Morton wrote:
> > #define EXPORT_SYMBOL_SELFTEST EXPORT_SYMBOL_GPL
> >
> > then write a script which checks the tree for usages of the
> > thus-tagged symbols outside tools/testing and lib/ (?)
> 
> and then yell at people? We can try it out of course. The namespace
> would be quite clear and we could document the supported usage pattern.
> We also want to make EXPORT_SYMBOL_SELFTEST conditional. EXPORTs are not
> free and we do not want to add them if the whole testing infrastructure
> is disabled (assuming there is a global one for that).

How about adding

#ifdef CONFIG_VMALLOC_TEST
int run_internal_vmalloc_tests(void)
{
...
}
EXPORT_SYMBOL_GPL(run_internal_vmalloc_tests);
#endif

to vmalloc.c?  That would also allow calling functions which are marked
as static, not just functions which aren't exported to modules.
