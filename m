Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id CEA488299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 08:49:16 -0400 (EDT)
Received: by widex7 with SMTP id ex7so5693764wid.1
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 05:49:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cf10si2921643wib.26.2015.03.13.05.49.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Mar 2015 05:49:15 -0700 (PDT)
Message-ID: <1426250948.28068.16.camel@stgolabs.net>
Subject: Re: [mmotm:master 326/344] ERROR: "get_mm_exe_file"
 [arch/x86/oprofile/oprofile.ko] undefined!
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 13 Mar 2015 05:49:08 -0700
In-Reply-To: <201503131130.Zapd2h6o%fengguang.wu@intel.com>
References: <201503131130.Zapd2h6o%fengguang.wu@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 2015-03-13 at 11:46 +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   da07e7d6fbb4e50396b37cd2b2ef7fcc0a9deb2e
> commit: 760a0a3d2a1d4f6c7ca51c0a5d9a9219310dd70d [326/344] oprofile: reduce mmap_sem hold for mm->exe_file
> config: x86_64-randconfig-c2-0313 (attached as .config)
> reproduce:
>   git checkout 760a0a3d2a1d4f6c7ca51c0a5d9a9219310dd70d
>   # save the attached .config to linux build tree
>   make ARCH=x86_64 
> 
> All error/warnings:
> 
> >> ERROR: "get_mm_exe_file" [arch/x86/oprofile/oprofile.ko] undefined!

I thought this was already fixed by Andrew
(https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=0439736d35ccc57a4817cb23f609631c93896a76)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
