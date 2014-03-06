Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E70C16B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:18:37 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id fp1so3092656pdb.28
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:18:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id zj6si6127157pac.30.2014.03.06.13.18.36
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 13:18:37 -0800 (PST)
Date: Thu, 6 Mar 2014 13:18:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 452/458] undefined reference to
 `__bad_size_call_parameter'
Message-Id: <20140306131835.543007307bf38e8986f1229c@linux-foundation.org>
In-Reply-To: <53188aab.D8+W+0kHpmaV0uFd%fengguang.wu@intel.com>
References: <53188aab.D8+W+0kHpmaV0uFd%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Thu, 06 Mar 2014 22:48:11 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   0ffb2fe7b9c30082876fa3a17da018bf0632cf03
> commit: 3b0fc5a9f85472be761e51de110e0aa8d15e7f41 [452/458] sh: replace __get_cpu_var uses
> config: make ARCH=sh r7785rp_defconfig
> 
> All error/warnings:
> 
>    arch/sh/kernel/built-in.o: In function `kprobe_exceptions_notify':
> >> (.kprobes.text+0x8c8): undefined reference to `__bad_size_call_parameter'

This has me stumped - the same code 

	p = __this_cpu_read(current_kprobe);

works OK elsewhere in that file.  I'm suspecting a miscompile - it's
not unknown for gcc to screw up when we use this trick.

I can reproduce it with gcc-3.4.5 for sh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
