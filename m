Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0E18D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 05:23:22 -0400 (EDT)
Date: Wed, 30 Mar 2011 05:23:17 -0400
From: 'Christoph Hellwig' <hch@infradead.org>
Subject: Re: XFS memory allocation deadlock in 2.6.38
Message-ID: <20110330092316.GA21819@infradead.org>
References: <20110324174311.GA31576@infradead.org>
 <AANLkTikwwRm6FHFtEdUg54NvmKdswQw-NPH5dtq1mXBK@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B5349@MSXAOA6.twosigma.com>
 <BANLkTin0jJevStg5P2hqsLbqMzo3o30sYg@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B534E@MSXAOA6.twosigma.com>
 <081DDE43F61F3D43929A181B477DCA95639B5359@MSXAOA6.twosigma.com>
 <20110329192434.GA10536@infradead.org>
 <081DDE43F61F3D43929A181B477DCA95639B535C@MSXAOA6.twosigma.com>
 <20110329200256.GA6019@infradead.org>
 <20110329224230.GH3008@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110329224230.GH3008@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: 'Christoph Hellwig' <hch@infradead.org>, Sean Noonan <Sean.Noonan@twosigma.com>, Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, Martin Bligh <Martin.Bligh@twosigma.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, Stephen Degler <Stephen.Degler@twosigma.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-xfs@oss.sgi.com'" <linux-xfs@oss.sgi.com>, 'Michel Lespinasse' <walken@google.com>

On Wed, Mar 30, 2011 at 09:42:30AM +1100, Dave Chinner wrote:
> > +#define MAX_VMALLOCS	6
> > +#define MAX_SLAB_SIZE	0x20000
> 
> Why those values for the magic numbers?

Ask the person who added it originall, it's just a revert to the
code before my commit to clean up our vmalloc usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
