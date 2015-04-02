Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AB7F46B006E
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 16:33:23 -0400 (EDT)
Received: by pactp5 with SMTP id tp5so94473982pac.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 13:33:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dm9si8968386pdb.103.2015.04.02.13.33.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 13:33:21 -0700 (PDT)
Date: Thu, 2 Apr 2015 13:33:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [memcg:since-3.19 477/542] fs/isofs/compress.c:193:1: warning:
 'zisofs_uncompress_block.constprop' uses dynamic stack allocation
Message-Id: <20150402133319.54a33257f49edf1274344f8d@linux-foundation.org>
In-Reply-To: <201504022011.DieE2tmc%fengguang.wu@intel.com>
References: <201504022011.DieE2tmc%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kbuild-all@01.org, Michal Hocko <mhocko@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 2 Apr 2015 20:16:14 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.19
> head:   9799825fa30ce564d2543540bd1988e8db80e757
> commit: 1645cf8131766f8135630a9e7cfd1928cd42cf66 [477/542] page-flags: define PG_uptodate behavior on compound pages
> config: s390-allyesconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 1645cf8131766f8135630a9e7cfd1928cd42cf66
>   # save the attached .config to linux build tree
>   make.cross ARCH=s390 
> 
> All warnings:
> 
>    fs/isofs/compress.c: In function 'zisofs_uncompress_block.constprop':
> >> fs/isofs/compress.c:193:1: warning: 'zisofs_uncompress_block.constprop' uses dynamic stack allocation
>     }
>     ^
>    fs/isofs/compress.c: In function 'zisofs_readpage':
>    fs/isofs/compress.c:360:1: warning: 'zisofs_readpage' uses dynamic stack allocation
>     }

afaict this is true in current mainline, and "page-flags: define
PG_uptodate behavior on compound pages" did nothing to cause this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
