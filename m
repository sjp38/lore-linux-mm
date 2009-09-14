Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1FD076B004F
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:50:42 -0400 (EDT)
Date: Mon, 14 Sep 2009 19:47:50 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090914164750.GB3745@redhat.com>
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AAE6A97.7090808@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Mon, Sep 14, 2009 at 12:08:55PM -0400, Gregory Haskins wrote:
> For Ira's example, the addresses would represent a physical address on
> the PCI boards, and would follow any kind of relevant rules for
> converting a "GPA" to a host accessible address (even if indirectly, via
> a dma controller).

I don't think limiting addresses to PCI physical addresses will work
well.  From what I rememeber, Ira's x86 can not initiate burst
transactions on PCI, and it's the ppc that initiates all DMA.

> 
> >  But we can't let the guest specify physical addresses.
> 
> Agreed.  Neither your proposal nor mine operate this way afaict.

But this seems to be what Ira needs.

> HTH
> 
> Kind Regards,
> -Greg
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
