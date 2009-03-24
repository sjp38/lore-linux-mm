Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F09BC6B0055
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 12:16:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D92AE82D0C9
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 12:35:34 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MKbkwMKw7pZS for <linux-mm@kvack.org>;
	Tue, 24 Mar 2009 12:35:34 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2F55382D0EB
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 12:35:30 -0400 (EDT)
Date: Tue, 24 Mar 2009 12:24:58 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: why my systems never cache more than ~900 MB?
In-Reply-To: <49C903B5.8020504@wpkg.org>
Message-ID: <alpine.DEB.1.10.0903241217150.30551@qirst.com>
References: <49C89CE0.2090103@wpkg.org> <200903250220.45575.nickpiggin@yahoo.com.au> <49C8FDD4.7070900@wpkg.org> <alpine.DEB.1.10.0903241142510.13587@qirst.com> <49C903B5.8020504@wpkg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Mar 2009, Tomasz Chmielewski wrote:

> Christoph Lameter schrieb:
> > On Tue, 24 Mar 2009, Tomasz Chmielewski wrote:
> >
> > > Nick Piggin schrieb:
> > > Does not help me, as what interests me here on these machines is mainly
> > > caching block device data; they are iSCSI targets and access block devices
> > > directly.
> >
> > You can run a 64 bit kernel on those machines. 64 bit kernels can use
> > 32 bit userspace without a problem. Just install an additional kernel and
> > try booting your existing setup with it.
> >
> > > What split should I choose to enable blockdev mapping on the whole memory
> > > on
> > > 32 bit system with 3 or 4 GB RAM? Is it possible with 4 GB RAM at all?
> >
> > A 64 bit kernel will do the trick.
>
> This hardware has problems booting 64 bit kernels (read: CPUs come from the
> 32-bit land).

Then the 1G/3G separation (VMSPLIT_1G) is the best you can do. Will use up
to 3G for low mem. Be aware that your I/O device must support DMA to full
32 bit addresses. If this is an old 32 bit machine with limitations on the
use of bit 31 then the box may have issues.

Put as much as you can into Highmem. Set HIGHMEM4G, HIGHPTE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
