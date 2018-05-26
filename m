Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19C356B0003
	for <linux-mm@kvack.org>; Sat, 26 May 2018 06:14:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3-v6so4353445pfe.15
        for <linux-mm@kvack.org>; Sat, 26 May 2018 03:14:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69-v6sor11651363pla.67.2018.05.26.03.14.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 03:14:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201805210314.e6bdStHL%fengguang.wu@intel.com>
References: <201805210314.e6bdStHL%fengguang.wu@intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 26 May 2018 12:14:04 +0200
Message-ID: <CACT4Y+bR+ywj_OtGDYiCp+PZ4MfdqfrXg5XQwN36uRnNCEHEZg@mail.gmail.com>
Subject: Re: [linux-next:master 5885/8111] /tmp/cc3gKKeM.s:35: Error: .err encountered
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, May 20, 2018 at 9:15 PM, kbuild test robot <lkp@intel.com> wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   fbbe3b8c2c9c5f84caf668703c26154cb4fbb9d1
> commit: 3b67022379d3d0c6a5cc5152f6b46eeea635a194 [5885/8111] arm: port KCOV to arm
> config: arm-allmodconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 3b67022379d3d0c6a5cc5152f6b46eeea635a194
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm
>
> All errors (new ones prefixed by >>):
>
>    /tmp/cc3gKKeM.s: Assembler messages:
>>> /tmp/cc3gKKeM.s:35: Error: .err encountered
>    /tmp/cc3gKKeM.s:36: Error: .err encountered
>    /tmp/cc3gKKeM.s:37: Error: .err encountered

I've tried to reproduce this following the instructions, but I failed,
build succeeds for me:
https://www.spinics.net/lists/linux-mm/msg152336.html
