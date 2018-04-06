Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3B16B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 07:06:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e185so711601wmg.5
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 04:06:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor4997636edk.28.2018.04.06.04.06.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 04:06:42 -0700 (PDT)
Date: Fri, 6 Apr 2018 14:05:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 0/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
Message-ID: <20180406110557.xg2edtjgzmsdksry@node.shutemov.name>
References: <20180228032657.32385-1-bhe@redhat.com>
 <20180405150842.350e4febc06a813138f00416@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405150842.350e4febc06a813138f00416@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com
Cc: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Thu, Apr 05, 2018 at 03:08:42PM -0700, Andrew Morton wrote:
> On Wed, 28 Feb 2018 11:26:53 +0800 Baoquan He <bhe@redhat.com> wrote:
> 
> > This is v3 post. V1 can be found here:
> > https://www.spinics.net/lists/linux-mm/msg144486.html
> > 
> > In sparse_init(), two temporary pointer arrays, usemap_map and map_map
> > are allocated with the size of NR_MEM_SECTIONS. They are used to store
> > each memory section's usemap and mem map if marked as present. In
> > 5-level paging mode, this will cost 512M memory though they will be
> > released at the end of sparse_init(). System with few memory, like
> > kdump kernel which usually only has about 256M, will fail to boot
> > because of allocation failure if CONFIG_X86_5LEVEL=y.
> > 
> > In this patchset, optimize the memmap allocation code to only use
> > usemap_map and map_map with the size of nr_present_sections. This
> > makes kdump kernel boot up with normal crashkernel='' setting when
> > CONFIG_X86_5LEVEL=y.
> 
> This patchset could do with some more review, please?

I don't really understand sparsemem good enough to comment on the
patchset.

Dave, could you review this?

-- 
 Kirill A. Shutemov
