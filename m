Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3093A6B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 05:59:29 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 27 Aug 2009 19:29:22 +0930
References: <cover.1250693417.git.mst@redhat.com> <20090825131634.GA13949@redhat.com> <20090826165655.GA23632@redhat.com>
In-Reply-To: <20090826165655.GA23632@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908271929.23454.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 27 Aug 2009 02:26:55 am Michael S. Tsirkin wrote:
> On Tue, Aug 25, 2009 at 04:16:34PM +0300, Michael S. Tsirkin wrote:
> > > > +	/* If they don't want an interrupt, don't send one, unless empty. */
> > > > +	if ((flags & VRING_AVAIL_F_NO_INTERRUPT) && vq->inflight)
> > > > +		return;
> > > 
> > > And I wouldn't support notify on empty at all, TBH.
> > 
> > If I don't, virtio net in guest uses a timer, which might be expensive.
> > Will need to check what this does.
> > 
> > >  It should
> > > definitely be conditional on the guest accepting the NOTIFY_ON_EMPTY
> > > feature.
> 
> lguest does not do it this way though, do it?

Does when a patch in my current queue is applied though.

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
