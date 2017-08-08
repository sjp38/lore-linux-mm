Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2836B02F4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:04:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r62so30936994pfj.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:04:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i1si845573plk.597.2017.08.08.05.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:04:54 -0700 (PDT)
Message-ID: <1502193889.5509.8.camel@linux.intel.com>
Subject: Re: [PATCH 01/21] mm/shmem: introduce shmem_file_setup_with_mnt
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Tue, 08 Aug 2017 15:04:49 +0300
In-Reply-To: <20170728131227.uxgmtl2vjs7rk5pp@node.shutemov.name>
References: <20170725192133.2012-1-matthew.auld@intel.com>
	 <20170725192133.2012-2-matthew.auld@intel.com>
	 <20170728131227.uxgmtl2vjs7rk5pp@node.shutemov.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, "Kirill
 A. Shutemov" <kirill@shutemov.name>, Matthew Auld <matthew.auld@intel.com>

Hi Hugh,

Could we get this patch merged? Or would you prefer us to merge through drm-tip?

For what it's worth, this is:

Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

Regards, Joonas

On pe, 2017-07-28 at 16:12 +0300, Kirill A. Shutemov wrote:
> On Tue, Jul 25, 2017 at 08:21:13PM +0100, Matthew Auld wrote:
> > 
> > We are planning to use our own tmpfs mnt in i915 in place of the
> > shm_mnt, such that we can control the mount options, in particular
> > huge=, which we require to support huge-gtt-pages. So rather than roll
> > our own version of __shmem_file_setup, it would be preferred if we could
> > just give shmem our mnt, and let it do the rest.
> > 
> > Signed-off-by: Matthew Auld <matthew.auld@intel.com>
> > Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> > Cc: Chris Wilson <chris@chris-wilson.co.uk>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: linux-mm@kvack.org
> 
> Looks okay to me.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
