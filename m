Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F08666B039F
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 17:09:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o126so46969072pfb.2
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:09:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s1si14620746plj.269.2017.04.10.14.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 14:09:58 -0700 (PDT)
Date: Mon, 10 Apr 2017 14:09:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 161/276] kernel/extable.c:174: undefined
 reference to `__start_ro_after_init'
Message-Id: <20170410140955.5a82e6f0fcb784c03ddd305c@linux-foundation.org>
In-Reply-To: <201704081021.kBB1nNuC%fengguang.wu@intel.com>
References: <201704081021.kBB1nNuC%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Eddie Kovsky <ewk@edkovsky.org>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Sat, 8 Apr 2017 10:37:22 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   5b220005fda0593464fc4549eea586e597bf783c
> commit: 7c61156608a0054d57061bd154b1ac537c49e0a8 [161/276] extable: verify address is read-only
> config: arm-efm32_defconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 7c61156608a0054d57061bd154b1ac537c49e0a8
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All errors (new ones prefixed by >>):
> 
>    kernel/built-in.o: In function `core_kernel_rodata':
> >> kernel/extable.c:174: undefined reference to `__start_ro_after_init'
> >> kernel/extable.c:174: undefined reference to `__end_ro_after_init'

Thanks, I dropped the patch.  And its companion
module-verify-address-is-read-only.patch to keep things tidy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
