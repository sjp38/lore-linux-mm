Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D35F66B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 08:03:42 -0400 (EDT)
Date: Sun, 13 Sep 2009 15:01:42 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090913120140.GA31218@redhat.com>
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AAA7415.5080204@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Fri, Sep 11, 2009 at 12:00:21PM -0400, Gregory Haskins wrote:
> FWIW: VBUS handles this situation via the "memctx" abstraction.  IOW,
> the memory is not assumed to be a userspace address.  Rather, it is a
> memctx-specific address, which can be userspace, or any other type
> (including hardware, dma-engine, etc).  As long as the memctx knows how
> to translate it, it will work.

How would permissions be handled? it's easy to allow an app to pass in
virtual addresses in its own address space.  But we can't let the guest
specify physical addresses.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
