Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C23C26B006A
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 23:10:05 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Date: Sun, 8 Nov 2009 14:39:59 +1030
References: <cover.1257267892.git.mst@redhat.com> <200911061531.20299.rusty@rustcorp.com.au> <20091106163007.GC6746@linux.vnet.ibm.com>
In-Reply-To: <20091106163007.GC6746@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911081439.59770.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Gregory Haskins <gregory.haskins@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Sat, 7 Nov 2009 03:00:07 am Paul E. McKenney wrote:
> On Fri, Nov 06, 2009 at 03:31:20PM +1030, Rusty Russell wrote:
> > But it's still nasty to use half an API.  If it were a few places I would
> > have open-coded it with a comment, or wrapped it.  As it is, I don't think
> > that would be a win.
> 
> So would it help to have a rcu_read_lock_workqueue() and
> rcu_read_unlock_workqueue() that checked nesting and whether they were
> actually running in the context of a workqueue item?  Or did you have
> something else in mind?  Or am I misjudging the level of sarcasm in
> your reply?  ;-)

You read correctly.  If we get a second user, creating an API makes sense.

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
