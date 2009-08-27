Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 93E3F6B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 06:46:55 -0400 (EDT)
Date: Thu, 27 Aug 2009 13:45:18 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090827104517.GB8545@redhat.com>
References: <cover.1250693417.git.mst@redhat.com> <20090819150309.GC4236@redhat.com> <200908252140.41295.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908252140.41295.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 09:40:40PM +0930, Rusty Russell wrote:
> Also, see other fixes to the lguest launcher since then which might
> be relevant to this code:
> 	lguest: get more serious about wmb() in example Launcher code

Heh, this just gets one step closer to a real wmb.  I just used the
correct code from linux, so I think nothing needs to be done in vhost.
Apropos this change in lguest: why is a compiler barrier sufficient? The
comment says devices are run in separate threads (presumably from
guest?), if so don't you need to tell CPU that there's a barrier as
well?

> 	lguest: clean up length-used value in example launcher

OK, fixing that.

Thanks!

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
