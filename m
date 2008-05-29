Date: Thu, 29 May 2008 10:59:16 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 07/23] hugetlb: multi hstate sysctls
Message-ID: <20080529085916.GB6881@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net> <20080529045919.GA8963@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080529045919.GA8963@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2008 at 09:59:19PM -0700, Nishanth Aravamudan wrote:
> On 26.05.2008 [00:23:24 +1000], npiggin@suse.de wrote:
> > Expand the hugetlbfs sysctls to handle arrays for all hstates. This
> > now allows the removal of global_hstate -- everything is now hstate
> > aware.
> > 
> > - I didn't bother with hugetlb_shm_group and treat_as_movable,
> > these are still single global.
> > - Also improve error propagation for the sysctl handlers a bit
> > 
> > Signed-off-by: Andi Kleen <ak@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> <snip>
> 
> >  int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
> >  			struct file *file, void __user *buffer,
> >  			size_t *length, loff_t *ppos)
> >  {
> > + 	table->maxlen = max_hstate * sizeof(int);
> 
> Are you sure this is correct? I was just testing my sysfs patch (and the
> removal of the multi-valued proc files) and noticed that
> /proc/sys/vm/hugepages_treat_as_movable was multi-valued (3 values,
> corresponding to the three page sizes on this machine), and the last
> value was garbage. And, in any case, this change seems to conflict with
> the changelog?

Hmm, might have slipped in during a merge. I'll fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
