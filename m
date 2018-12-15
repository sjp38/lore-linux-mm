Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 46A038E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:30:04 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h11so6035584pfj.13
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 20:30:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d13sor10927133pgi.71.2018.12.14.20.30.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 20:30:02 -0800 (PST)
Subject: Re: [mmotm:master 187/302] mm/page_io.c:405:18: error: 'REQ_HIPRI'
 undeclared; did you mean 'RWF_HIPRI'?
References: <201812150739.LplJThib%fengguang.wu@intel.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <4553850c-9084-7209-eecf-36abc77a58ea@kernel.dk>
Date: Fri, 14 Dec 2018 21:29:59 -0700
MIME-Version: 1.0
In-Reply-To: <201812150739.LplJThib%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 12/14/18 4:04 PM, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   6d5b029d523e959579667282e713106a29c193d2
> commit: 80509a64e354a3de67cfe4dee1cf51c8a2512e44 [187/302] mm/page_io.c: fix polled swap page in
> config: x86_64-rhel-7.2-clear (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         git checkout 80509a64e354a3de67cfe4dee1cf51c8a2512e44
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: the mmotm/master HEAD 6d5b029d523e959579667282e713106a29c193d2 builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>    mm/page_io.c: In function 'swap_readpage':
>>> mm/page_io.c:405:18: error: 'REQ_HIPRI' undeclared (first use in this function); did you mean 'RWF_HIPRI'?
>       bio->bi_opf |= REQ_HIPRI;
>                      ^~~~~~~~~
>                      RWF_HIPRI
>    mm/page_io.c:405:18: note: each undeclared identifier is reported only once for each function it appears in

The patch just needs to be ordered after the block tree in -mm, then
there are no concerns.

-- 
Jens Axboe
