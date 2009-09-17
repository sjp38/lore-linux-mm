Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 576AB6B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 01:40:28 -0400 (EDT)
Date: Thu, 17 Sep 2009 08:38:18 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 1/2] mm: export use_mm/unuse_mm to modules
Message-ID: <20090917053817.GB6770@redhat.com>
References: <cover.1249992497.git.mst@redhat.com> <20090811212752.GB26309@redhat.com> <20090811151010.c9c56955.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090811151010.c9c56955.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, hpa@zytor.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,
On Tue, Aug 11, 2009 at 03:10:10PM -0700, Andrew Morton wrote:
> On Wed, 12 Aug 2009 00:27:52 +0300
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > vhost net module wants to do copy to/from user from a kernel thread,
> > which needs use_mm (like what fs/aio has).  Move that into mm/ and
> > export to modules.
> 
> OK by me.  Please include this change in the virtio patchset.  Which I
> shall cheerfully not be looking at :)

The virtio patches are somewhat delayed as we are ironing out the
kernel/user interface with Rusty. Can the patch moving use_mm to mm/ be
applied without exporting to modules for now? This will make it easier
for virtio which will only have to patch in the EXPORT line.

I also have a small patch optimizing atomic usage in use_mm (which I did for
virtio) and it's easier to apply it if the code is in the new place.

If ok, pls let me know and I'll post the patch without the EXPORT line.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
