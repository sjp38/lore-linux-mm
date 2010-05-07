Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F097962007F
	for <linux-mm@kvack.org>; Thu,  6 May 2010 23:05:49 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio: put last_used and last_avail index into ring itself.
Date: Fri, 7 May 2010 12:35:39 +0930
References: <cover.1257349249.git.mst@redhat.com> <201005061022.13815.rusty@rustcorp.com.au> <20100506062755.GC8363@redhat.com>
In-Reply-To: <20100506062755.GC8363@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201005071235.40590.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 May 2010 03:57:55 pm Michael S. Tsirkin wrote:
> On Thu, May 06, 2010 at 10:22:12AM +0930, Rusty Russell wrote:
> > On Wed, 5 May 2010 03:52:36 am Michael S. Tsirkin wrote:
> > > What do you think?
> > 
> > I think everyone is settled on 128 byte cache lines for the forseeable
> > future, so it's not really an issue.
> 
> You mean with 64 bit descriptors we will be bouncing a cache line
> between host and guest, anyway?

I'm confused by this entire thread.

Descriptors are 16 bytes.  They are at the start, so presumably aligned to
cache boundaries.

Available ring follows that at 2 bytes per entry, so it's also packed nicely
into cachelines.

Then there's padding to page boundary.  That puts us on a cacheline again
for the used ring; also 2 bytes per entry.

I don't see how any change in layout could be more cache friendly?
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
