Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D802C6B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 14:22:10 -0500 (EST)
Date: Wed, 4 Nov 2009 21:19:26 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv8 0/3] vhost: a kernel-level virtio server
Message-ID: <20091104191926.GC772@redhat.com>
References: <20091104155234.GA32673@redhat.com> <4AF1A587.8000509@gmail.com> <20091104162339.GA311@redhat.com> <4AF1D2DE.10705@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AF1D2DE.10705@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 02:15:42PM -0500, Gregory Haskins wrote:
> Michael S. Tsirkin wrote:
> > On Wed, Nov 04, 2009 at 11:02:15AM -0500, Gregory Haskins wrote:
> >> Michael S. Tsirkin wrote:
> >>> Ok, I think I've addressed all comments so far here.
> >>> Rusty, I'd like this to go into linux-next, through your tree, and
> >>> hopefully 2.6.33.  What do you think?
> >> I think the benchmark data is a prerequisite for merge consideration, IMO.
> > 
> > Shirley Ma was kind enough to send me some measurement results showing
> > how kernel level acceleration helps speed up you can find them here:
> > http://www.linux-kvm.org/page/VhostNet
> 
> Thanks for the pointers.  I will roll your latest v8 code into our test
> matrix.  What kernel/qemu trees do they apply to?
> 
> -Greg
> 


kernel 2.6.32-rc6, qemu-kvm 47e465f031fc43c53ea8f08fa55cc3482c6435c8.
You can also use my development git trees if you like.

kernel:
git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost
userspace:
git://git.kernel.org/pub/scm/linux/kernel/git/mst/qemu-kvm.git vhost

Please note I rebase especially userspace tree now and when.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
