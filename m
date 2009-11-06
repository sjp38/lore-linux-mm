Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D89156B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 00:01:24 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Date: Fri, 6 Nov 2009 15:31:20 +1030
References: <cover.1257267892.git.mst@redhat.com> <20091104115729.GD8398@redhat.com> <20091104172542.GC6736@linux.vnet.ibm.com>
In-Reply-To: <20091104172542.GC6736@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911061531.20299.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Gregory Haskins <gregory.haskins@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009 03:55:42 am Paul E. McKenney wrote:
> On Wed, Nov 04, 2009 at 01:57:29PM +0200, Michael S. Tsirkin wrote:
> > Can you ack this usage please?
> 
> I thought I had done so in my paragraph above, but if you would like
> something a bit more formal...

<snip verbose super-ack with qualifications>

That's great guys.  And yes, this is a kind of read-copy-update.  And no,
there's nothing wrong with it.

But it's still nasty to use half an API.  If it were a few places I would
have open-coded it with a comment, or wrapped it.  As it is, I don't think
that would be a win.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
