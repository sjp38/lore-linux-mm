Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id A27D36B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:59:28 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so2127050iec.17
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 12:59:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pg8si2700988igb.59.2014.06.25.12.59.27
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 12:59:28 -0700 (PDT)
Date: Wed, 25 Jun 2014 12:59:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 156/212] fs/binfmt_elf.c:158:18: note: in
 expansion of macro 'min'
Message-Id: <20140625125926.127128b7bb82cb5dc9c7e01c@linux-foundation.org>
In-Reply-To: <53AAB2D3.2050809@oracle.com>
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com>
	<20140625100213.GA1866@localhost>
	<53AAB2D3.2050809@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 25 Jun 2014 19:30:27 +0800 Jeff Liu <jeff.liu@oracle.com> wrote:

> 
> On 06/25/2014 18:02 PM, Fengguang Wu wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   30404ddcb1872c8a571fa0889935ff65677e4c78
> > commit: aef93cafef35b8830fc973be43f0745f9c16eff4 [156/212] binfmt_elf.c: use get_random_int() to fix entropy depleting
> > config: make ARCH=mn10300 asb2364_defconfig
> > 
> > All warnings:
> > 
> >    In file included from include/asm-generic/bug.h:13:0,
> >                     from arch/mn10300/include/asm/bug.h:35,
> >                     from include/linux/bug.h:4,
> >                     from include/linux/thread_info.h:11,
> >                     from include/asm-generic/preempt.h:4,
> >                     from arch/mn10300/include/generated/asm/preempt.h:1,
> >                     from include/linux/preempt.h:18,
> >                     from include/linux/spinlock.h:50,
> >                     from include/linux/seqlock.h:35,
> >                     from include/linux/time.h:5,
> >                     from include/linux/stat.h:18,
> >                     from include/linux/module.h:10,
> >                     from fs/binfmt_elf.c:12:
> >    fs/binfmt_elf.c: In function 'get_atrandom_bytes':
> >    include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
> >      (void) (&_min1 == &_min2);  \
> >                     ^
> >>> fs/binfmt_elf.c:158:18: note: in expansion of macro 'min'
> >       size_t chunk = min(nbytes, sizeof(random_variable));
> 
> I remember we have the same report on arch mn10300 about half a year ago, but the code
> is correct. :)

We really need to do something about this patch - it's been stuck in
-mm for ever.

I have a note here that Stephan Mueller identified issues with it but I
don't recall what they were - do you? 

Maybe you could go back through the list dicussion, identify all/any
issues which were raised, update the changelog to address them then
resend it, copying people who were involved in the earlier discussion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
