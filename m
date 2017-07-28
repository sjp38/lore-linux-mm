Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21E886B0543
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:12:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g71so16013474wmg.13
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:12:31 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id i28si17131920wrc.136.2017.07.28.06.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 06:12:30 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id m85so21687138wma.0
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:12:29 -0700 (PDT)
Date: Fri, 28 Jul 2017 16:12:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/21] mm/shmem: introduce shmem_file_setup_with_mnt
Message-ID: <20170728131227.uxgmtl2vjs7rk5pp@node.shutemov.name>
References: <20170725192133.2012-1-matthew.auld@intel.com>
 <20170725192133.2012-2-matthew.auld@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725192133.2012-2-matthew.auld@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>
Cc: intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Tue, Jul 25, 2017 at 08:21:13PM +0100, Matthew Auld wrote:
> We are planning to use our own tmpfs mnt in i915 in place of the
> shm_mnt, such that we can control the mount options, in particular
> huge=, which we require to support huge-gtt-pages. So rather than roll
> our own version of __shmem_file_setup, it would be preferred if we could
> just give shmem our mnt, and let it do the rest.
> 
> Signed-off-by: Matthew Auld <matthew.auld@intel.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org

Looks okay to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
