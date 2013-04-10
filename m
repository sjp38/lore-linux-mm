Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 6677C6B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:15:10 -0400 (EDT)
Date: Wed, 10 Apr 2013 15:15:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 81/499] WARNING: mm/built-in.o(.text+0x1acc1):
 Section mismatch in reference from the function reserve_mem_notifier() to
 the function .meminit.text:init_user_reserve()
Message-Id: <20130410151508.b25d2082a7d81496fafd380e@linux-foundation.org>
In-Reply-To: <CAF-E8XEPpbqfytcsz3XGuYf06hOUrkj4rcUaahEFfWA-e4NPhQ@mail.gmail.com>
References: <CAF-E8XEPpbqfytcsz3XGuYf06hOUrkj4rcUaahEFfWA-e4NPhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 10 Apr 2013 16:04:11 -0600 Andrew Shewmaker <agshew@gmail.com> wrote:

> On Wed, Apr 10, 2013 at 12:11 AM, kbuild test robot
> <fengguang.wu@intel.com> wrote:
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   47ca352cea8ba679f803387d208c739131ecb38a
> > commit: 992357a07ee0697a1997c2960c3f88d02b2f2753 [81/499] mm: reinititalise user and admin reserves if memory is added or removed
> > config: x86_64-randconfig-a00-0410 (attached as .config)
> >
> > All warnings:
> >
> >>> WARNING: mm/built-in.o(.text+0x1acc1): Section mismatch in reference from the function reserve_mem_notifier() to the function .meminit.text:init_user_reserve()
> >    The function reserve_mem_notifier() references
> >    the function __meminit init_user_reserve().
> >    This is often because reserve_mem_notifier lacks a __meminit
> >    annotation or the annotation of init_user_reserve is wrong.
> > --
> >>> WARNING: mm/built-in.o(.text+0x1acd8): Section mismatch in reference from the function reserve_mem_notifier() to the function .meminit.text:init_admin_reserve()
> >    The function reserve_mem_notifier() references
> >    the function __meminit init_admin_reserve().
> >    This is often because reserve_mem_notifier lacks a __meminit
> >    annotation or the annotation of init_admin_reserve is wrong.
> 
> Andrew, am I right in thinking that functions annotated with __meminit may
> be discarded? If so, then I should drop the annotation from init_user_reserve()
> and init_admin_reserve() since the memory notifier uses them to reinitialize
> memory, right?

Yes.  And init_user_reserve() and init_admin_reserve() can be made static. 
I'll fix everything up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
