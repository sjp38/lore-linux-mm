Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 25D976B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:03:42 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so9207904pad.0
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 11:03:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id zt8si20910183pbc.255.2014.03.11.11.03.40
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 11:03:41 -0700 (PDT)
Date: Tue, 11 Mar 2014 11:03:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2014-03-10-15-35 uploaded (virtio_balloon)
Message-Id: <20140311110338.333e1ee691cadb0f20dbb083@linux-foundation.org>
In-Reply-To: <531F43F2.1030504@infradead.org>
References: <20140310223701.0969C31C2AA@corp2gmr1-1.hot.corp.google.com>
	<531F43F2.1030504@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, virtio-dev@lists.oasis-open.org, "Michael S. Tsirkin" <mst@redhat.com>, Josh Triplett <josh@joshtriplett.org>

On Tue, 11 Mar 2014 10:12:18 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:

> On 03/10/2014 03:37 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2014-03-10-15-35 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> > You will need quilt to apply these patches to the latest Linus release (3.x
> > or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > http://ozlabs.org/~akpm/mmotm/series
> > 
> > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> > followed by the base kernel version against which this patch series is to
> > be applied.
> > 
> > This tree is partially included in linux-next.  To see which patches are
> > included in linux-next, consult the `series' file.  Only the patches
> > within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
> > linux-next.
> > 
> 
> on x86_64:
> 
> ERROR: "balloon_devinfo_alloc" [drivers/virtio/virtio_balloon.ko] undefined!
> ERROR: "balloon_page_enqueue" [drivers/virtio/virtio_balloon.ko] undefined!
> ERROR: "balloon_page_dequeue" [drivers/virtio/virtio_balloon.ko] undefined!
> 
> when loadable module
> 
> or
> 
> virtio_balloon.c:(.text+0x1fa26): undefined reference to `balloon_page_enqueue'
> virtio_balloon.c:(.text+0x1fb87): undefined reference to `balloon_page_dequeue'
> virtio_balloon.c:(.text+0x1fdf1): undefined reference to `balloon_devinfo_alloc'
> 
> when builtin.

OK, thanks, I'll drop
http://ozlabs.org/~akpm/mmots/broken-out/mm-disable-mm-balloon_compactionc-completely-when-config_balloon_compaction.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
