Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 5823E6B0072
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 05:20:48 -0400 (EDT)
Date: Mon, 15 Oct 2012 10:20:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 19/33] autonuma: memory follows CPU algorithm and
 task/mm_autonuma stats collection
Message-ID: <20121015092044.GU3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-20-git-send-email-aarcange@redhat.com>
 <20121013180618.GC31442@linux.vnet.ibm.com>
 <20121015082413.GD17364@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121015082413.GD17364@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, pzijlstr@redhat.com, mingo@elte.hu, hughd@google.com, riel@redhat.com, hannes@cmpxchg.org, dhillf@gmail.com, drjones@redhat.com, tglx@linutronix.de, pjt@google.com, cl@linux.com, suresh.b.siddha@intel.com, efault@gmx.de, paulmck@linux.vnet.ibm.com, laijs@cn.fujitsu.com, Lee.Schermerhorn@hp.com, alex.shi@intel.com, benh@kernel.crashing.org

On Mon, Oct 15, 2012 at 01:54:13PM +0530, Srikar Dronamraju wrote:
> * Srikar Dronamraju <srikar@linux.vnet.ibm.com> [2012-10-13 23:36:18]:
> 
> > > +
> > > +bool numa_hinting_fault(struct page *page, int numpages)
> > > +{
> > > +	bool migrated = false;
> > > +
> > > +	/*
> > > +	 * "current->mm" could be different from the "mm" where the
> > > +	 * NUMA hinting page fault happened, if get_user_pages()
> > > +	 * triggered the fault on some other process "mm". That is ok,
> > > +	 * all we care about is to count the "page_nid" access on the
> > > +	 * current->task_autonuma, even if the page belongs to a
> > > +	 * different "mm".
> > > +	 */
> > > +	WARN_ON_ONCE(!current->mm);
> > 
> > Given the above comment, Do we really need this warn_on?
> > I think I have seen this warning when using autonuma.
> > 
> 
> ------------[ cut here ]------------
> WARNING: at ../mm/autonuma.c:359 numa_hinting_fault+0x60d/0x7c0()
> Hardware name: BladeCenter HS22V -[7871AC1]-
> Modules linked in: ebtable_nat ebtables autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf bridge stp llc iptable_filter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vhost_net macvtap macvlan tun iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii kvm_intel kvm microcode serio_raw lpc_ich mfd_core i2c_i801 i2c_core shpchp ioatdma i7core_edac edac_core bnx2 ixgbe dca mdio sg ext4 mbcache jbd2 sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas dm_mirror dm_region_hash dm_log dm_mod
> Pid: 116, comm: ksmd Tainted: G      D      3.6.0-autonuma27+ #3

The kernel is tainted "D" which implies that it has already oopsed
before this warning was triggered. What was the other oops?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
