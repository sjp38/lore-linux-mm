Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2737A6B0033
	for <linux-mm@kvack.org>; Sat,  4 Feb 2017 03:27:29 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so9006629wmi.6
        for <linux-mm@kvack.org>; Sat, 04 Feb 2017 00:27:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v13si20772676wrc.50.2017.02.04.00.27.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 04 Feb 2017 00:27:27 -0800 (PST)
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
References: <201702041041.pT43t4Op%fengguang.wu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9128099d-16fc-0adc-42f0-f286522ebec0@suse.cz>
Date: Sat, 4 Feb 2017 09:27:21 +0100
MIME-Version: 1.0
In-Reply-To: <201702041041.pT43t4Op%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, kbuild-all@01.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On 4.2.2017 3:26, kbuild test robot wrote:
> Hi Vlastimil,
> 
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on v4.10-rc6]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

Hi,

there are no warnings below?

Vlastimil

> 
> url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/mm-slab-rename-kmalloc-node-cache-to-kmalloc-size/20170204-021843
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-allmodconfig
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         make ARCH=i386  allmodconfig
>         make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
