Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAF6128025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:51:58 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so80952230pfv.5
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:51:58 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id de3si5135697pad.0.2016.11.10.09.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:51:57 -0800 (PST)
Date: Thu, 10 Nov 2016 20:51:53 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161110175153.o6mnjovli4ocil56@black.fi.intel.com>
References: <20161110162540.GA12743@node.shutemov.name>
 <201611110147.n5fpiarv%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201611110147.n5fpiarv%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, kbuild-all@01.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 11, 2016 at 01:42:47AM +0800, kbuild test robot wrote:
> Hi Kirill,
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.9-rc4 next-20161110]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Kirill-A-Shutemov/shmem-avoid-huge-pages-for-small-files/20161111-005428
> config: i386-randconfig-s0-201645 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>    mm/shmem.c: In function 'shmem_getpage_gfp':
> >> mm/shmem.c:1680:12: warning: unused variable 'off' [-Wunused-variable]
>        pgoff_t off;
