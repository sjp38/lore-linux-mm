Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7D84D900009
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 08:30:46 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so7348704wgh.35
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 05:30:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cg8si7804874wib.8.2014.07.09.05.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jul 2014 05:30:45 -0700 (PDT)
Date: Wed, 9 Jul 2014 08:30:28 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [next:master 284/379] :undefined reference to
 `crypto_alloc_shash'
Message-ID: <20140709123028.GB26504@redhat.com>
References: <53bd23e5.Zuv44zZmJKnR/Dh5%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53bd23e5.Zuv44zZmJKnR/Dh5%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On Wed, Jul 09, 2014 at 07:13:41PM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   35fcf5dd2a7d038c0fcbc161e353d73497350b86
> commit: ba0dc4038c9fec5fa2f94756065f02b8011f270b [284/379] kexec: load and relocate purgatory at kernel load time
> config: make ARCH=arm nuc950_defconfig
> 
> All error/warnings:
> 
>    kernel/built-in.o: In function `sys_kexec_file_load':
> >> :(.text+0x4c808): undefined reference to `crypto_alloc_shash'
> >> :(.text+0x4c8d4): undefined reference to `crypto_shash_update'
> >> :(.text+0x4c918): undefined reference to `crypto_shash_update'
> >> :(.text+0x4c9f4): undefined reference to `crypto_shash_final'
> 

Hi,

This issue has been fixed by following patch.

http://ozlabs.org/~akpm/mmots/broken-out/kexec-load-and-relocate-purgatory-at-kernel-load-time-fix.patch

This should go away when above patch shows up in linux-next.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
