Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9328A6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 08:35:23 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so158540wgh.23
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 05:35:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c11si35343613wjs.107.2014.07.03.05.35.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 05:35:04 -0700 (PDT)
Date: Thu, 3 Jul 2014 08:34:54 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [mmotm:master 289/396] undefined reference to
 `crypto_alloc_shash'
Message-ID: <20140703123454.GB21156@redhat.com>
References: <53b49bda.Alc8D1c/m4kIm3gZ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53b49bda.Alc8D1c/m4kIm3gZ%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Thu, Jul 03, 2014 at 07:55:06AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   82b56f797fa200a5e9feac3a93cb6496909b9670
> commit: 025d75374c9c08274f60da5802381a8ef7490388 [289/396] kexec: load and relocate purgatory at kernel load time
> config: make ARCH=s390 allnoconfig
> 
> All error/warnings:
> 
>    kernel/built-in.o: In function `sys_kexec_file_load':
>    (.text+0x32314): undefined reference to `crypto_shash_final'
>    kernel/built-in.o: In function `sys_kexec_file_load':
>    (.text+0x32328): undefined reference to `crypto_shash_update'
>    kernel/built-in.o: In function `sys_kexec_file_load':
> >> (.text+0x32338): undefined reference to `crypto_alloc_shash'

Hi,

Now generic kexec implementation requires CRYPTO and CRYPTI_SHA256. Hence
I select these in arch/x86/Kconfig.

config KEXEC
        bool "kexec system call"
        select BUILD_BIN2C
        select CRYPTO
        select CRYPTO_SHA256

But I realize that I did not do it for other arches which have KEXEC
defined. And that will lead to failure on other arches.

I will write a patch now and create this additional dependency in
all other arch Kconfig files which support KEXEC.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
