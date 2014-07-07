Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 66CB5900003
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 15:04:17 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so5927149pab.32
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 12:04:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n8si5164150pdr.498.2014.07.07.12.04.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 12:04:16 -0700 (PDT)
Date: Mon, 7 Jul 2014 12:04:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 284/380] cpu_pm.c:undefined reference to
 `crypto_alloc_shash'
Message-Id: <20140707120414.2cb6c1da2b71a91c24ced4aa@linux-foundation.org>
In-Reply-To: <53b516e4.rgxkJyIm0d6ktGNY%fengguang.wu@intel.com>
References: <53b516e4.rgxkJyIm0d6ktGNY%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Thu, 03 Jul 2014 16:40:04 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   0e9ce823ad7bc6b85c279223ae6638d47089461e
> commit: ba0dc4038c9fec5fa2f94756065f02b8011f270b [284/380] kexec: load and relocate purgatory at kernel load time
> config: make ARCH=arm nuc950_defconfig
> 
> All error/warnings:
> 
>    kernel/built-in.o: In function `sys_kexec_file_load':
> >> cpu_pm.c:(.text+0x4a580): undefined reference to `crypto_alloc_shash'
> >> cpu_pm.c:(.text+0x4a654): undefined reference to `crypto_shash_update'
> >> cpu_pm.c:(.text+0x4a698): undefined reference to `crypto_shash_update'
> >> cpu_pm.c:(.text+0x4a778): undefined reference to `crypto_shash_final'

yup, kexec now requires crypto but the patch only fixes x86's Kconfig.

Was selecting crypto the correct decision?  Is there no case for using
kexec without this signing capability?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
