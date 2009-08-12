Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3E3836B005C
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 09:41:51 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
Date: Wed, 12 Aug 2009 15:40:44 +0200
References: <20090811212743.GA26309@redhat.com> <200908121452.01802.arnd@arndb.de> <20090812130612.GC29200@redhat.com>
In-Reply-To: <20090812130612.GC29200@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908121540.44928.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Gregory Haskins <gregory.haskins@gmail.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, Patrick Mullaney <pmullaney@novell.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 12 August 2009, Michael S. Tsirkin wrote:
> > If I understand it correctly, you can at least connect a veth pair
> > to a bridge, right? Something like
> > 
> >            veth0 - veth1 - vhost - guest 1 
> > eth0 - br0-|
> >            veth2 - veth3 - vhost - guest 2
> >            
> Heh, you don't need a bridge in this picture:
> 
> guest 1 - vhost - veth0 - veth1 - vhost guest 2

Sure, but the setup I described is the one that I would expect
to see in practice because it gives you external connectivity.

Measuring two guests communicating over a veth pair is
interesting for finding the bottlenecks, but of little
practical relevance.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
