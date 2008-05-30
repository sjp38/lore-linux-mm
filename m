Date: Fri, 30 May 2008 05:51:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 2/2] hugetlb: remove multi-valued proc files.
Message-ID: <20080530035123.GB25792@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net> <20080529063915.GC11357@us.ibm.com> <20080529064242.GD11357@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080529064242.GD11357@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2008 at 11:42:42PM -0700, Nishanth Aravamudan wrote:
> Now that we present the same information in a cleaner way in sysfs, we
> can remove the duplicate information and interfaces from procfs (and
> consider them to be the legacy interface). The proc interface only
> controls the default hugepage size, which is either
> 
> a) the first one specified via hugepagesz= on the kernel command-line, if any
> b) the legacy huge page size, otherwise
> 
> All other hugepage size pool manipulations can occur through sysfs.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> ---
> Note, this does end up making the manipulation and validation of
> multiple hstates impossible without sysfs enabled and mounted. As such,

I don't think that's such a problem. The overlap between users with
no sysfs and those that use multiple hugepages won't be large. And
if any exist, they can specify at boot or come up with their own
customer solution.


> I'm not sure if this is the right approach and perhaps we should be
> leaving the multi-valued proc files in place (but not as the preferred
> interface). Or we could present the values in procfs only if SYSFS is
> not enabled in the kernel? I imagine (but am not 100% sure) that the
> only current architecture where this might be important is SUPERH?

I wouldn't worry too much. I think /proc/sys/vm/nr_hugepages etc
is better as one (the compat) value after we now have the sysfs
stuff. However /proc/meminfo is a little more tricky. Of course
the information does exist in sysfs too, but meminfo is also for
user reporting, so maybe it will be better to leave it multi
column?


> Nick, this includes the fix to make hugepages_treat_as_movable
> single-valued again, which presumably will get thrown up as a merge
> conflict if it's fixed at the right place in the stack.

Thanks.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
