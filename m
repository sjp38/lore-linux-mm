Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A97466B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:22:55 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Date: Wed, 16 Sep 2009 17:22:37 +0200
References: <20090914164750.GB3745@redhat.com> <200909161657.42628.arnd@arndb.de> <20090916151329.GC5513@redhat.com>
In-Reply-To: <20090916151329.GC5513@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909161722.37606.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Gregory Haskins <gregory.haskins@gmail.com>, Avi Kivity <avi@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wednesday 16 September 2009, Michael S. Tsirkin wrote:
> On Wed, Sep 16, 2009 at 04:57:42PM +0200, Arnd Bergmann wrote:
> > On Tuesday 15 September 2009, Michael S. Tsirkin wrote:
> > > Userspace in x86 maps a PCI region, uses it for communication with ppc?
> > 
> > This might have portability issues. On x86 it should work, but if the
> > host is powerpc or similar, you cannot reliably access PCI I/O memory
> > through copy_tofrom_user but have to use memcpy_toio/fromio or readl/writel
> > calls, which don't work on user pointers.
> > 
> > Specifically on powerpc, copy_from_user cannot access unaligned buffers
> > if they are on an I/O mapping.
> > 
> We are talking about doing this in userspace, not in kernel.

Ok, that's fine then. I thought the idea was to use the vhost_net driver
to access the user memory, which would be a really cute hack otherwise,
as you'd only need to provide the eventfds from a hardware specific
driver and could use the regular virtio_net on the other side.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
