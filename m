Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F07E56B0055
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:59:16 -0400 (EDT)
Date: Thu, 17 Sep 2009 06:57:17 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090917035717.GB3088@redhat.com>
References: <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AB0F1EF.5050102@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 10:10:55AM -0400, Gregory Haskins wrote:
> > There is no role reversal.
> 
> So if I have virtio-blk driver running on the x86 and vhost-blk device
> running on the ppc board, I can use the ppc board as a block-device.
> What if I really wanted to go the other way?

It seems ppc is the only one that can initiate DMA to an arbitrary
address, so you can't do this really, or you can by tunneling each
request back to ppc, or doing an extra data copy, but it's unlikely to
work well.

The limitation comes from hardware, not from the API we use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
