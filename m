Date: Fri, 27 Sep 2002 22:44:24 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.38-mm3
Message-ID: <20020927224424.A28529@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20020927152833.D25021@in.ibm.com> <502559422.1033113869@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502559422.1033113869@[10.10.2.3]>; from mbligh@aracnet.com on Fri, Sep 27, 2002 at 08:04:31AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Zwane Mwaikambo <zwane@linuxpower.ca>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 27, 2002 at 08:04:31AM -0700, Martin J. Bligh wrote:
> >> > What application were you all running ?
> 
> Kernel compile on NUMA-Q looks like this:
> 
> 125673 total
> 82183 default_idle
> 2288 d_lookup
> 1921 vm_enough_memory
> 1883 __generic_copy_from_user
> 1566 file_read_actor
> 1381 .text.lock.file_table           <-------------

More likely, this is contention for the files_lock. Do you have any 
lockmeter data ?  That should give us more information. If so,
the files_struct_rcu isn't likely to help.

> 1168 find_get_page
> 1116 get_empty_filp
> 
> Presumably that's the same thing? Interestingly, if I look back at 
> previous results, I see it's about twice the cost in -mm as it is 
> in mainline, not sure why ... at least against 2.5.37 virgin it was.

Not sure why it shows up more in -mm, but likely because -mm has
lot less contention on other locks like dcache_lock.

> 
> > Please try running the files_struct_rcu patch where fget() is lockfree
> > and let me know what you see.
> 
> Will do ... if you tell me where it is ;-)

Oh, the usual place -
http://sourceforge.net/project/showfiles.php?group_id=8875&release_id=112473
I wish sourceforge FRS continued to allow direct links to patches.

Thanks
-- 
Dipankar Sarma  <dipankar@in.ibm.com> http://lse.sourceforge.net
Linux Technology Center, IBM Software Lab, Bangalore, India.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
