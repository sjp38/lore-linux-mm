Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 35E656B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 17:23:46 -0400 (EDT)
Received: by igui7 with SMTP id i7so93472671igu.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 14:23:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 23si13010725iom.203.2015.08.18.14.23.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 14:23:45 -0700 (PDT)
Date: Tue, 18 Aug 2015 14:23:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 506/522] frv-linux-ld: Warning: size of symbol
 `sys_membarrier' changed from 8 in kernel/sys_ni.o to 52 in
 kernel/membarrier.o
Message-Id: <20150818142343.67b06e32577b6b77d8fb8478@linux-foundation.org>
In-Reply-To: <201508180946.7ISLU3CL%fengguang.wu@intel.com>
References: <201508180946.7ISLU3CL%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>

On Tue, 18 Aug 2015 09:43:48 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   ef4ce68013dd78948da68460aab14b59563998d0
> commit: a91c5d8940ac0be6c80a796ddf6a2ddae5242c58 [506/522] sgi-xp: replace cpu_to_node() with cpu_to_mem() to support memoryless node
> config: frv-defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout a91c5d8940ac0be6c80a796ddf6a2ddae5242c58
>   # save the attached .config to linux build tree
>   make.cross ARCH=frv 
> 
> All warnings (new ones prefixed by >>):
> 
>    frv-linux-ld: Warning: size of symbol `sys_setuid' changed from 272 in kernel/sys.o to 8 in kernel/sys_ni.o
>    frv-linux-ld: Warning: size of symbol `sys_setregid' changed from 328 in kernel/sys.o to 8 in kernel/sys_ni.o
>    frv-linux-ld: Warning: size of symbol `sys_setgid' changed from 212 in kernel/sys.o to 8 in kernel/sys_ni.o
> ...

Something appears to be screwed up in the FRV toolchain's handling of
weak symbols.

Possibly this is due to our implementation of cond_syscall().  I assume
this doesn't happen with C symbols which are declared __weak, so
perhaps someone who has an FRV compiler can look at the compiler's
assembly output for a __weak C symbol, compare that with the
cond_syscall() implementation and see if the difference suggests a fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
