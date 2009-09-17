Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E27B56B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 01:43:49 -0400 (EDT)
Date: Wed, 16 Sep 2009 22:43:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 1/2] mm: export use_mm/unuse_mm to modules
Message-Id: <20090916224345.3b5212b4.akpm@linux-foundation.org>
In-Reply-To: <20090917053817.GB6770@redhat.com>
References: <cover.1249992497.git.mst@redhat.com>
	<20090811212752.GB26309@redhat.com>
	<20090811151010.c9c56955.akpm@linux-foundation.org>
	<20090917053817.GB6770@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, hpa@zytor.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 08:38:18 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:

> Hi Andrew,
> On Tue, Aug 11, 2009 at 03:10:10PM -0700, Andrew Morton wrote:
> > On Wed, 12 Aug 2009 00:27:52 +0300
> > "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > 
> > > vhost net module wants to do copy to/from user from a kernel thread,
> > > which needs use_mm (like what fs/aio has).  Move that into mm/ and
> > > export to modules.
> > 
> > OK by me.  Please include this change in the virtio patchset.  Which I
> > shall cheerfully not be looking at :)
> 
> The virtio patches are somewhat delayed as we are ironing out the
> kernel/user interface with Rusty. Can the patch moving use_mm to mm/ be
> applied without exporting to modules for now? This will make it easier
> for virtio which will only have to patch in the EXPORT line.

That was 10,000 patches ago.

> I also have a small patch optimizing atomic usage in use_mm (which I did for
> virtio) and it's easier to apply it if the code is in the new place.
> 
> If ok, pls let me know and I'll post the patch without the EXPORT line.

Please just send them all out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
