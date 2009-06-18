Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 787C86B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 15:06:56 -0400 (EDT)
Subject: Re: [PATCH 5/5] Update huge pages kernel documentation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <9ec263480906181149t1aac592o57ce517bdd749cf5@mail.gmail.com>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook>
	 <20090616135315.25248.7893.sendpatchset@lts-notebook>
	 <9ec263480906181149t1aac592o57ce517bdd749cf5@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 18 Jun 2009 15:06:58 -0400
Message-Id: <1245352018.1025.86.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-06-18 at 11:49 -0700, David Rientjes wrote:
> On Tue, Jun 16, 2009 at 6:53 AM, Lee
> Schermerhorn<lee.schermerhorn@hp.com> wrote:
> > @@ -67,26 +65,76 @@ use either the mmap system call or share
> >  the huge pages.  It is required that the system administrator preallocate
> >  enough memory for huge page purposes.
> >
> > -Use the following command to dynamically allocate/deallocate hugepages:
> > +The administrator can preallocate huge pages on the kernel boot command line by
> > +specifying the "hugepages=N" parameter, where 'N' = the number of huge pages
> > +requested.  This is the most reliable method for preallocating huge pages as
> > +memory has not yet become fragmented.
> > +
> > +Some platforms support multiple huge page sizes.  To preallocate huge pages
> > +of a specific size, one must preceed the huge pages boot command parameters
> > +with a huge page size selection parameter "hugepagesz=<size>".  <size> must
> > +be specified in bytes with optional scale suffix [kKmMgG].  The default huge
> > +page size may be selected with the "default_hugepagesz=<size>" boot parameter.
> > +
> > +/proc/sys/vm/nr_hugepages indicates the current number of configured [default
> > +size] hugetlb pages in the kernel.  Super user can dynamically request more
> > +(or free some pre-configured) hugepages.
> > +
> > +Use the following command to dynamically allocate/deallocate default sized
> > +hugepages:
> >
> >        echo 20 > /proc/sys/vm/nr_hugepages
> >
> > -This command will try to configure 20 hugepages in the system.  The success
> > -or failure of allocation depends on the amount of physically contiguous
> > -memory that is preset in system at this time.  System administrators may want
> > -to put this command in one of the local rc init files.  This will enable the
> > -kernel to request huge pages early in the boot process (when the possibility
> > -of getting physical contiguous pages is still very high). In either
> > -case, administrators will want to verify the number of hugepages actually
> > -allocated by checking the sysctl or meminfo.
> > +This command will try to configure 20 default sized hugepages in the system.
> > +On a NUMA platform, the kernel will attempt to distribute the hugepage pool
> > +over the nodes specified by the /proc/sys/vm/hugepages_nodes_allowed node mask.
> > +hugepages_nodes_allowed defaults to all on-line nodes.
> > +
> > +To control the nodes on which huge pages are preallocated, the administrator
> > +may set the hugepages_nodes_allowed for the default huge page size using:
> > +
> > +       echo <nodelist> >/proc/sys/vm/hugepages_nodes_allowed
> > +
> 
> This probably also needs an update to
> Documentation/ABI/testing/sysfs-kernel-mm-hugepages for the
> non-default hstate nodes_allowed.


Thanks, David.  I'll take a look and address that in the next respin of
the series.  If you've been following the exchange with Mel, you'll know
that the approach may change quite a bit.  However it ends up, I'll
update the abi testing doc or yell for help.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
