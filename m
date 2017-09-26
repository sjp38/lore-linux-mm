Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E464F6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 03:52:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r136so11043428wmf.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 00:52:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 12si6737442wrw.465.2017.09.26.00.52.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 00:52:14 -0700 (PDT)
Date: Tue, 26 Sep 2017 09:52:21 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 02/22] drm/i915: introduce simple gemfs
Message-ID: <20170926075221.GB32088@kroah.com>
References: <20170925184737.8807-1-matthew.auld@intel.com>
 <20170925184737.8807-3-matthew.auld@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925184737.8807-3-matthew.auld@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>
Cc: intel-gfx@lists.freedesktop.org, devel@driverdev.osuosl.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Hugh Dickins <hughd@google.com>, Riley Andrews <riandrews@android.com>, dri-devel@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Sep 25, 2017 at 07:47:17PM +0100, Matthew Auld wrote:
> Not a fully blown gemfs, just our very own tmpfs kernel mount. Doing so
> moves us away from the shmemfs shm_mnt, and gives us the much needed
> flexibility to do things like set our own mount options, namely huge=
> which should allow us to enable the use of transparent-huge-pages for
> our shmem backed objects.
> 
> v2: various improvements suggested by Joonas
> 
> v3: move gemfs instance to i915.mm and simplify now that we have
> file_setup_with_mnt
> 
> v4: fallback to tmpfs shm_mnt upon failure to setup gemfs
> 
> v5: make tmpfs fallback kinder

Why do this only for one specific driver?  Shouldn't the drm core handle
this for you, for all other drivers as well?  Otherwise trying to figure
out how to "contain" this type of thing is going to be a pain (mount
options, selinux options, etc.)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
