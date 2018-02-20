Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2C26B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 20:21:24 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 1so6243928oiq.8
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 17:21:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f187si32205oic.532.2018.02.19.17.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Feb 2018 17:21:23 -0800 (PST)
Date: Tue, 20 Feb 2018 12:21:11 +1100
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: [RFC PATCH v16 0/6] mm: security: ro protection for dynamic data
Message-ID: <20180220012111.GC3728@rh>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <CAGXu5j+ZNFX17Vxd37rPnkahFepFn77Fi9zEy+OL8nNd_2bjqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+ZNFX17Vxd37rPnkahFepFn77Fi9zEy+OL8nNd_2bjqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Mon, Feb 12, 2018 at 03:32:36PM -0800, Kees Cook wrote:
> On Mon, Feb 12, 2018 at 8:52 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> > This patch-set introduces the possibility of protecting memory that has
> > been allocated dynamically.
> >
> > The memory is managed in pools: when a memory pool is turned into R/O,
> > all the memory that is part of it, will become R/O.
> >
> > A R/O pool can be destroyed, to recover its memory, but it cannot be
> > turned back into R/W mode.
> >
> > This is intentional. This feature is meant for data that doesn't need
> > further modifications after initialization.
> 
> This series came up in discussions with Dave Chinner (and Matthew
> Wilcox, already part of the discussion, and others) at LCA. I wonder
> if XFS would make a good initial user of this, as it could allocate
> all the function pointers and other const information about a
> superblock in pmalloc(), keeping it separate from the R/W portions?
> Could other filesystems do similar things?

I wasn't cc'd on this patchset, (please use david@fromorbit.com for
future postings) so I can't really say anything about it right
now. My interest for XFS was that we have a fair amount of static
data in XFS that we set up at mount time and it never gets modified
after that. I'm not so worried about VFS level objects (that's a
much more complex issue) but there is a lot of low hanging fruit in
the XFS structures we could convert to write-once structures.

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
