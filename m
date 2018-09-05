Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DEC56B74E0
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 16:01:16 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22-v6so4286736plq.21
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 13:01:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q17-v6si3014147pfi.183.2018.09.05.13.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 13:01:15 -0700 (PDT)
Date: Wed, 5 Sep 2018 13:01:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 58/135] fs//cramfs/inode.c:423:10: error:
 implicit declaration of function 'vm_insert_mixed'; did you mean
 'vmf_insert_mixed'?
Message-Id: <20180905130113.8e271d3e63af41538310e776@linux-foundation.org>
In-Reply-To: <201809051035.i3MAJfsz%fengguang.wu@intel.com>
References: <201809051035.i3MAJfsz%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 5 Sep 2018 10:09:42 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   b99ef2cad77986ffd5818c8baeacef456d92e33d
> commit: 8842588f1d870eb196bfdb7d9c3c64df1a691f20 [58/135] mm: remove vm_insert_mixed()
> config: ia64-allmodconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 8.1.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 8842588f1d870eb196bfdb7d9c3c64df1a691f20
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.1.0 make.cross ARCH=ia64 
> 
> Note: the mmotm/master HEAD b99ef2cad77986ffd5818c8baeacef456d92e33d builds fine.
>       It only hurts bisectibility.

Thanks, I reordered the patches.
