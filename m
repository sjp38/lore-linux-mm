Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 452986B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:04:33 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id i20so2256325qad.11
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:04:32 -0700 (PDT)
MIME-Version: 1.0
From: Andrew Shewmaker <agshew@gmail.com>
Date: Wed, 10 Apr 2013 16:04:11 -0600
Message-ID: <CAF-E8XEPpbqfytcsz3XGuYf06hOUrkj4rcUaahEFfWA-e4NPhQ@mail.gmail.com>
Subject: Re: [mmotm:master 81/499] WARNING: mm/built-in.o(.text+0x1acc1):
 Section mismatch in reference from the function reserve_mem_notifier() to the
 function .meminit.text:init_user_reserve()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 10, 2013 at 12:11 AM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   47ca352cea8ba679f803387d208c739131ecb38a
> commit: 992357a07ee0697a1997c2960c3f88d02b2f2753 [81/499] mm: reinititalise user and admin reserves if memory is added or removed
> config: x86_64-randconfig-a00-0410 (attached as .config)
>
> All warnings:
>
>>> WARNING: mm/built-in.o(.text+0x1acc1): Section mismatch in reference from the function reserve_mem_notifier() to the function .meminit.text:init_user_reserve()
>    The function reserve_mem_notifier() references
>    the function __meminit init_user_reserve().
>    This is often because reserve_mem_notifier lacks a __meminit
>    annotation or the annotation of init_user_reserve is wrong.
> --
>>> WARNING: mm/built-in.o(.text+0x1acd8): Section mismatch in reference from the function reserve_mem_notifier() to the function .meminit.text:init_admin_reserve()
>    The function reserve_mem_notifier() references
>    the function __meminit init_admin_reserve().
>    This is often because reserve_mem_notifier lacks a __meminit
>    annotation or the annotation of init_admin_reserve is wrong.

Andrew, am I right in thinking that functions annotated with __meminit may
be discarded? If so, then I should drop the annotation from init_user_reserve()
and init_admin_reserve() since the memory notifier uses them to reinitialize
memory, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
