Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F6BA6B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:58:26 -0400 (EDT)
Date: Wed, 26 Aug 2009 19:56:55 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090826165655.GA23632@redhat.com>
References: <cover.1250693417.git.mst@redhat.com> <20090819150309.GC4236@redhat.com> <200908252140.41295.rusty@rustcorp.com.au> <20090825131634.GA13949@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090825131634.GA13949@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 04:16:34PM +0300, Michael S. Tsirkin wrote:
> > > +	/* If they don't want an interrupt, don't send one, unless empty. */
> > > +	if ((flags & VRING_AVAIL_F_NO_INTERRUPT) && vq->inflight)
> > > +		return;
> > 
> > And I wouldn't support notify on empty at all, TBH.
> 
> If I don't, virtio net in guest uses a timer, which might be expensive.
> Will need to check what this does.
> 
> >  It should
> > definitely be conditional on the guest accepting the NOTIFY_ON_EMPTY
> > feature.

lguest does not do it this way though, do it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
