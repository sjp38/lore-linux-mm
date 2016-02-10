Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 047076B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 14:52:36 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id ho8so16714203pac.2
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 11:52:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y4si7002494par.45.2016.02.10.11.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 11:52:35 -0800 (PST)
Date: Wed, 10 Feb 2016 11:52:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: undefined reference to `efi_call'
Message-Id: <20160210115234.234e2bab71db2028c98b58ad@linux-foundation.org>
In-Reply-To: <201602101626.jtqGm2RN%fengguang.wu@intel.com>
References: <201602101626.jtqGm2RN%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Linux Memory Management List <linux-mm@kvack.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, 10 Feb 2016 16:48:28 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> Hi Johannes,
> 
> It's probably a bug fix that unveils the link errors.
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   2178cbc68f3602dc0b5949b9be2c8383ad3d93ef
> commit: 489c2a20a414351fe0813a727c34600c0f7292ae mm: memcontrol: introduce CONFIG_MEMCG_LEGACY_KMEM
> date:   3 weeks ago
> config: x86_64-randconfig-s3-02101458 (attached as .config)
> reproduce:
>         git checkout 489c2a20a414351fe0813a727c34600c0f7292ae
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/x86/built-in.o: In function `uv_bios_call':
> >> (.text+0xeba00): undefined reference to `efi_call'

I'd be surprised if the above patch caused this.

CONFIG_EFI=n

CONFIG_X86_UV does not depend on EFI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
