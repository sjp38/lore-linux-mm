Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97EA06B0696
	for <linux-mm@kvack.org>; Fri, 18 May 2018 18:10:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k1-v6so3231842pgq.20
        for <linux-mm@kvack.org>; Fri, 18 May 2018 15:10:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 33-v6si8390872plt.596.2018.05.18.15.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 15:10:05 -0700 (PDT)
Date: Fri, 18 May 2018 15:10:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 149/199] lib/idr.c:583:2: error: implicit
 declaration of function 'xa_lock_irqsave'; did you mean
 'read_lock_irqsave'?
Message-Id: <20180518151000.93517f28f3338bb39f558a90@linux-foundation.org>
In-Reply-To: <201805190415.2D1H4m65%fengguang.wu@intel.com>
References: <201805190415.2D1H4m65%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 19 May 2018 04:21:17 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   7400fc6942aefa2e009272d0e118284f110c5088
> commit: d5f90621ff2af7f139b01b7bcf8649a91665965e [149/199] lib/idr.c: remove simple_ida_lock
> config: x86_64-randconfig-i0-201819 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         git checkout d5f90621ff2af7f139b01b7bcf8649a91665965e
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: the mmotm/master HEAD 7400fc6942aefa2e009272d0e118284f110c5088 builds fine.
>       It only hurts bisectibility.
> 

I'm a bit surprised we're seeing this. 
ida-remove-simple_ida_lock.patch introduces this error, and the very
next patch ida-remove-simple_ida_lock-fix.patch fixes it.

I'm pretty sure that the robot software is capable of detecting this
situation and ignoring the error.  Did that code get broken?
