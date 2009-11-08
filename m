Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE4956B004D
	for <linux-mm@kvack.org>; Sun,  8 Nov 2009 14:36:33 -0500 (EST)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nA8JYeSo020449
	for <linux-mm@kvack.org>; Sun, 8 Nov 2009 14:34:40 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nA8JaTqP104124
	for <linux-mm@kvack.org>; Sun, 8 Nov 2009 14:36:29 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nA8JaSw6015213
	for <linux-mm@kvack.org>; Sun, 8 Nov 2009 14:36:29 -0500
Date: Sun, 8 Nov 2009 11:36:33 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20091108193633.GL8424@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1257267892.git.mst@redhat.com> <200911061531.20299.rusty@rustcorp.com.au> <20091106163007.GC6746@linux.vnet.ibm.com> <200911081439.59770.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911081439.59770.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Gregory Haskins <gregory.haskins@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Sun, Nov 08, 2009 at 02:39:59PM +1030, Rusty Russell wrote:
> On Sat, 7 Nov 2009 03:00:07 am Paul E. McKenney wrote:
> > On Fri, Nov 06, 2009 at 03:31:20PM +1030, Rusty Russell wrote:
> > > But it's still nasty to use half an API.  If it were a few places I would
> > > have open-coded it with a comment, or wrapped it.  As it is, I don't think
> > > that would be a win.
> > 
> > So would it help to have a rcu_read_lock_workqueue() and
> > rcu_read_unlock_workqueue() that checked nesting and whether they were
> > actually running in the context of a workqueue item?  Or did you have
> > something else in mind?  Or am I misjudging the level of sarcasm in
> > your reply?  ;-)
> 
> You read correctly.  If we get a second user, creating an API makes sense.

Makes sense to me as well.  Which does provide some time to come up with
a primitive designed to answer the question "Am I currently executing in
the context of a workqueue item?".  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
