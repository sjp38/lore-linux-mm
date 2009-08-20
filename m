Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 26E5C6B004F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 11:13:17 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 20 Aug 2009 17:10:31 +0200
References: <cover.1250187913.git.mst@redhat.com> <200908201631.37285.arnd@arndb.de> <20090820144256.GB8338@redhat.com>
In-Reply-To: <20090820144256.GB8338@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908201710.31723.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Thursday 20 August 2009, Michael S. Tsirkin wrote:
> 
> > The errors from the socket (or chardev, as that was the
> > start of the argument) should still fit into the categories
> > that I mentioned, either they can be handled by the host
> > kernel, or they are fatal.
> 
> Hmm, are you sure? Imagine a device going away while socket is bound to
> it.  You get -ENXIO. It's not fatal in a sense that you can bind the
> socket to another device and go on, right?

Right. Not fatal in that sense, but fatal in the sense that I
can no longer transmit other frames until you recover. I think
we both meant the same here.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
