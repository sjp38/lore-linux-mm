Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25E9F6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 11:32:57 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id i1-v6so9527723pld.11
        for <linux-mm@kvack.org>; Tue, 29 May 2018 08:32:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g21-v6sor2589914plq.120.2018.05.29.08.32.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 08:32:56 -0700 (PDT)
Date: Wed, 30 May 2018 00:32:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [linux-stable-rc:linux-4.14.y 3879/4798]
 kernel//time/posix-timers.c:1231:1: note: in expansion of macro
 'COMPAT_SYSCALL_DEFINE4'
Message-ID: <20180529153252.GB521@tigerII.localdomain>
References: <201805292323.ZKQwkUJy%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805292323.ZKQwkUJy%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On (05/29/18 23:23), kbuild test robot wrote:
> Hi Sergey,
> 
> First bad commit (maybe != root cause):
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-4.14.y
> head:   9fcb9d72e8a3a813caae6e2fac43a73603d75abd
> commit: 8e99c881e497e7f7528f693c563e204ae888a846 [3879/4798] tools/lib/subcmd/pager.c: do not alias select() params
> config: x86_64-acpi-redef (attached as .config)
> compiler: gcc-8 (Debian 8.1.0-3) 8.1.0
> reproduce:
>         git checkout 8e99c881e497e7f7528f693c563e204ae888a846
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 

Hello,

The commit in question is for a user space tool. I don't think it has
anything to do with the __SYSCALL_DEFINEx macro.

Seems that you have switched to gcc-8.1, which has aliasing warning ON
by default.

	-ss
