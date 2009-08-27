Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3FBB86B005A
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 07:21:30 -0400 (EDT)
Date: Thu, 27 Aug 2009 14:19:48 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090827111947.GA21801@redhat.com>
References: <cover.1250693417.git.mst@redhat.com> <200908252140.41295.rusty@rustcorp.com.au> <20090827104517.GB8545@redhat.com> <200908272040.02628.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908272040.02628.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Aug 27, 2009 at 08:40:02PM +0930, Rusty Russell wrote:
> On Thu, 27 Aug 2009 08:15:18 pm Michael S. Tsirkin wrote:
> > On Tue, Aug 25, 2009 at 09:40:40PM +0930, Rusty Russell wrote:
> > > Also, see other fixes to the lguest launcher since then which might
> > > be relevant to this code:
> > > 	lguest: get more serious about wmb() in example Launcher code
> > 
> > Heh, this just gets one step closer to a real wmb.  I just used the
> > correct code from linux, so I think nothing needs to be done in vhost.
> > Apropos this change in lguest: why is a compiler barrier sufficient? The
> > comment says devices are run in separate threads (presumably from
> > guest?), if so don't you need to tell CPU that there's a barrier as
> > well?
> 
> Yep, but x86 only :)

Okay, writes are ordered them. But mb() orders reads as well,
so it'll have to have a real one IMO, even in userspace?

>  The kernel uses a real insn if XMM/XMM2, but I don't
> know if userspace needs that.  I just use compiler barriers.
> 
> Thanks,
> Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
