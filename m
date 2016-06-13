Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3A41828EE
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 17:11:29 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id he1so87531159pac.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 14:11:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o124si34154171pfb.247.2016.06.13.14.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 14:11:29 -0700 (PDT)
Date: Mon, 13 Jun 2016 14:11:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mel:mm-vmscan-node-lru-v7r3 38/200] slub.c:undefined reference
 to `cache_random_seq_create'
Message-Id: <20160613141123.fcb245b6a7fd3199ae8a32d7@linux-foundation.org>
In-Reply-To: <201606140353.WeDaHl1M%fengguang.wu@intel.com>
References: <201606140353.WeDaHl1M%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 14 Jun 2016 03:37:57 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mel/linux mm-vmscan-node-lru-v7r3
> head:   276a5614a25ce20248f42bd4fb025b80ae0c9be1
> commit: 44c61fe5d7f13025a2a1f6efbbc0da75ad93ee19 [38/200] mm: SLUB freelist randomization
> config: x86_64-randconfig-x018-06140033 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         git checkout 44c61fe5d7f13025a2a1f6efbbc0da75ad93ee19
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/built-in.o: In function `init_cache_random_seq':
> >> slub.c:(.text+0x507dc): undefined reference to `cache_random_seq_create'
>    mm/built-in.o: In function `__kmem_cache_release':
> >> (.text+0x53979): undefined reference to `cache_random_seq_destroy'

I don't even get that far with that .config.  With gcc-4.4.4 I get

init/built-in.o: In function `initcall_blacklisted':
main.c:(.text+0x41): undefined reference to `__stack_chk_guard'
main.c:(.text+0xbe): undefined reference to `__stack_chk_guard'
init/built-in.o: In function `do_one_initcall':
(.text+0xeb): undefined reference to `__stack_chk_guard'
init/built-in.o: In function `do_one_initcall':
(.text+0x22b): undefined reference to `__stack_chk_guard'
init/built-in.o: In function `name_to_dev_t':
(.text+0x320): undefined reference to `__stack_chk_guard'
init/built-in.o:(.text+0x52e): more undefined references to `__stack_chk_guard' 

Kees touched it last :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
