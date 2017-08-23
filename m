Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 884762803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 18:35:00 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m85so1392367wma.1
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 15:35:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m3si445198wmb.155.2017.08.23.15.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 15:34:59 -0700 (PDT)
Date: Wed, 23 Aug 2017 15:34:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/23] mm/shmem: introduce shmem_file_setup_with_mnt
Message-Id: <20170823153456.b3c50e1ec109fd69f672b348@linux-foundation.org>
In-Reply-To: <1503480688.6276.4.camel@linux.intel.com>
References: <20170821183503.12246-1-matthew.auld@intel.com>
	<20170821183503.12246-2-matthew.auld@intel.com>
	<1503480688.6276.4.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Matthew Auld <matthew.auld@intel.com>, intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, 23 Aug 2017 12:31:28 +0300 Joonas Lahtinen <joonas.lahtinen@linux.intel.com> wrote:

> This patch has been floating around for a while now Acked and without
> further comments. It is blocking us from merging huge page support to
> drm/i915.
> 
> Would you mind merging it, or prodding the right people to get it in?
> 
> Regards, Joonas
> 
> On Mon, 2017-08-21 at 19:34 +0100, Matthew Auld wrote:
> > We are planning to use our own tmpfs mnt in i915 in place of the
> > shm_mnt, such that we can control the mount options, in particular
> > huge=, which we require to support huge-gtt-pages. So rather than roll
> > our own version of __shmem_file_setup, it would be preferred if we could
> > just give shmem our mnt, and let it do the rest.

hm, it's a bit odd.  I'm having trouble locating the code which handles
huge=within_size (and any other options?).  What other approaches were
considered?  Was it not feasible to add i915-specific mount options to
mm/shmem.c (for example?).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
