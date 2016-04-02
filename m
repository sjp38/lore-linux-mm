Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D0D976B007E
	for <linux-mm@kvack.org>; Sat,  2 Apr 2016 17:54:47 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fe3so116231087pab.1
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 14:54:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id g70si15508112pfg.32.2016.04.02.14.54.47
        for <linux-mm@kvack.org>;
        Sat, 02 Apr 2016 14:54:47 -0700 (PDT)
Date: Sun, 3 Apr 2016 00:54:30 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 0/3] mm/mmap.c: don't unmap the overlapping VMA(s)
Message-ID: <20160402215430.GA100607@black.fi.intel.com>
References: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mtk.manpages@gmail.com, cmetcalf@mellanox.com, arnd@arndb.de, viro@zeniv.linux.org.uk, mszeredi@suse.cz, dave@stgolabs.net, vbabka@suse.cz, mingo@kernel.org, dan.j.williams@intel.com, dave.hansen@linux.intel.com, koct9i@gmail.com, hannes@cmpxchg.org, jack@suse.cz, xiexiuqi@huawei.com, iamjoonsoo.kim@lge.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, rientjes@google.com, denc716@gmail.com, toshi.kani@hpe.com, ldufour@linux.vnet.ibm.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Sat, Apr 02, 2016 at 09:17:31PM +0200, Piotr Kwapulinski wrote:
> @@ -19,6 +19,7 @@
>  #define MAP_TYPE	0x0f		/* Mask for type of mapping */
>  #define MAP_FIXED	0x10		/* Interpret addr exactly */
>  #define MAP_ANONYMOUS	0x20		/* don't use a file */
> +#define MAP_DONTUNMAP	0x40		/* don't unmap overlapping VMA */

NAK.

arch/powerpc/include/uapi/asm/mman.h:#define MAP_NORESERVE   0x40            /* don't reserve swap pages */
arch/sparc/include/uapi/asm/mman.h:#define MAP_NORESERVE   0x40            /* don't reserve swap pages */
arch/x86/include/uapi/asm/mman.h:#define MAP_32BIT      0x40            /* only give out 32bit addresses */

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
