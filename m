Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40D516B251D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 12:16:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r2-v6so1321159pgp.3
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 09:16:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f90-v6si2040354plf.30.2018.08.22.09.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 09:16:38 -0700 (PDT)
Date: Wed, 22 Aug 2018 09:16:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 171/242] kernel/exit.c:640:3: error: too few
 arguments to function 'group_send_sig_info'
Message-Id: <20180822091636.995e8432a4099f4530164e66@linux-foundation.org>
In-Reply-To: <201808221952.N6cXyeWC%fengguang.wu@intel.com>
References: <201808221952.N6cXyeWC%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: =?ISO-8859-1?Q?J=FCrg?= Billeter <j@bitron.ch>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, 22 Aug 2018 19:33:13 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   10b78d76f1897885d7753586ecd113e9d6728c5d
> commit: 467d84a6210ea3c079b10393349a52f051d9bb95 [171/242] prctl: add PR_[GS]ET_PDEATHSIG_PROC
> config: i386-tinyconfig (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         git checkout 467d84a6210ea3c079b10393349a52f051d9bb95
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> Note: the mmotm/master HEAD 10b78d76f1897885d7753586ecd113e9d6728c5d builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>    kernel/exit.c: In function 'reparent_leader':
> >> kernel/exit.c:640:3: error: too few arguments to function 'group_send_sig_info'
>       group_send_sig_info(p->signal->pdeath_signal_proc,
>       ^~~~~~~~~~~~~~~~~~~

OK, thanks.  Linus had some issues with that patch anyway - I'll drop
it.
