Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 808806B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 15:42:19 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so40862257pab.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:42:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rd8si14770310pab.25.2015.11.11.12.41.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 12:41:13 -0800 (PST)
Date: Wed, 11 Nov 2015 12:41:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 12891/13017] mm/slub.c:2396:1: warning:
 '___slab_alloc' uses dynamic stack allocation
Message-Id: <20151111124108.53df1f48218c1366f9e763f0@linux-foundation.org>
In-Reply-To: <201511111413.65wysS6A%fengguang.wu@intel.com>
References: <201511111413.65wysS6A%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Wed, 11 Nov 2015 14:34:19 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   2bba65ab5f9f1cebd21d95c410b96952851f58b3
> commit: e191357c4c31d02eb30736a49327ef32407fab47 [12891/13017] slub: create new ___slab_alloc function that can be called with irqs disabled
> config: s390-allmodconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout e191357c4c31d02eb30736a49327ef32407fab47
>         # save the attached .config to linux build tree
>         make.cross ARCH=s390 
> 
> All warnings (new ones prefixed by >>):
> 
>    mm/slub.c: In function 'unfreeze_partials.isra.42':
>    mm/slub.c:2019:1: warning: 'unfreeze_partials.isra.42' uses dynamic stack allocation
>     }
>     ^
>    mm/slub.c: In function 'get_partial_node.isra.43':
>    mm/slub.c:1654:1: warning: 'get_partial_node.isra.43' uses dynamic stack allocation
>     }
>     ^
>    mm/slub.c: In function 'deactivate_slab':
>    mm/slub.c:1951:1: warning: 'deactivate_slab' uses dynamic stack allocation
>     }
>     ^
>    mm/slub.c: In function '__slab_free':
>    mm/slub.c:2696:1: warning: '__slab_free' uses dynamic stack allocation
>     }
>     ^
>    mm/slub.c: In function '___slab_alloc':
> >> mm/slub.c:2396:1: warning: '___slab_alloc' uses dynamic stack allocation
>     }
>     ^

This patch doesn't add any dynamic stack allocations.  The fact that
slub.c already had a bunch of these warnings makes me suspect that it's
happening in one of the s390 headers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
