Date: Thu, 26 Sep 2002 05:29:09 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.38-mm3
Message-ID: <20020926122909.GN3530@holomorphy.com>
References: <3D92BE07.B6CDFE54@digeo.com> <20020926175445.B18906@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020926175445.B18906@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dipankar Sarma <dipankar@in.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 26, 2002 at 05:54:45PM +0530, Dipankar Sarma wrote:
> Updated 2.5.38 RCU core and dcache_rcu patches are now available
> at http://sourceforge.net/project/showfiles.php?group_id=8875&release_id=112473
> The differences since earlier versions are -
> rcu_ltimer - call_rcu() fixed for preemption and the earlier fix I had sent
>              to you.
> read_barrier_depends - fixes list_for_each_rcu macro compilation error.
> dcache_rcu - uses list_add_rcu in d_rehash and list_for_each_rcu in d_lookup
>              making the read_barrier_depends() fix I had sent to you
>              earlier unnecessary.

Is there an update to the files_struct stuff too? I'm seeing large
overheads there also.


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
