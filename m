Date: Thu, 26 Sep 2002 18:10:52 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.38-mm3
Message-ID: <20020926181052.C18906@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <3D92BE07.B6CDFE54@digeo.com> <20020926175445.B18906@in.ibm.com> <20020926122909.GN3530@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020926122909.GN3530@holomorphy.com>; from wli@holomorphy.com on Thu, Sep 26, 2002 at 05:29:09AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 26, 2002 at 05:29:09AM -0700, William Lee Irwin III wrote:
> On Thu, Sep 26, 2002 at 05:54:45PM +0530, Dipankar Sarma wrote:
> > Updated 2.5.38 RCU core and dcache_rcu patches are now available
> > at http://sourceforge.net/project/showfiles.php?group_id=8875&release_id=112473
> > The differences since earlier versions are -
> > rcu_ltimer - call_rcu() fixed for preemption and the earlier fix I had sent
> >              to you.
> > read_barrier_depends - fixes list_for_each_rcu macro compilation error.
> > dcache_rcu - uses list_add_rcu in d_rehash and list_for_each_rcu in d_lookup
> >              making the read_barrier_depends() fix I had sent to you
> >              earlier unnecessary.
> 
> Is there an update to the files_struct stuff too? I'm seeing large
> overheads there also.

files_struct_rcu is not in mm kernels, but I will upload the most
recent version to the same download directory in LSE.

I would be interested in fget() profile count change with that patch.

Thanks
-- 
Dipankar Sarma  <dipankar@in.ibm.com> http://lse.sourceforge.net
Linux Technology Center, IBM Software Lab, Bangalore, India.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
