Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 982136B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 10:57:46 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Date: Wed, 16 Sep 2009 16:57:42 +0200
References: <20090914164750.GB3745@redhat.com> <4AAFFC8E.9010404@gmail.com> <20090915212545.GC27954@redhat.com>
In-Reply-To: <20090915212545.GC27954@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909161657.42628.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Gregory Haskins <gregory.haskins@gmail.com>, Avi Kivity <avi@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tuesday 15 September 2009, Michael S. Tsirkin wrote:
> Userspace in x86 maps a PCI region, uses it for communication with ppc?

This might have portability issues. On x86 it should work, but if the
host is powerpc or similar, you cannot reliably access PCI I/O memory
through copy_tofrom_user but have to use memcpy_toio/fromio or readl/writel
calls, which don't work on user pointers.

Specifically on powerpc, copy_from_user cannot access unaligned buffers
if they are on an I/O mapping.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
