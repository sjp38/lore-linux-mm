Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3SHMmSu024045
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 13:22:48 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3SHMf2t263534
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 13:22:41 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3SHMecP020138
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 13:22:41 -0400
Date: Mon, 28 Apr 2008 10:22:39 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080428172239.GA24169@us.ibm.com>
References: <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com> <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com> <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080427051029.GA22858@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.04.2008 [22:10:29 -0700], Greg KH wrote:
> On Sat, Apr 26, 2008 at 08:49:42PM -0700, Nishanth Aravamudan wrote:
> > 
> > [20:41:56]nacc@arkanoid:/sys/kernel/hugepages$ cat /sys/kernel/hugepages/hugepages-2MB/meminfo
> > HugePages_Total:     0
> > HugePages_Free:      0
> > HugePages_Rsvd:      0
> > HugePages_Surp:      0
> > Hugepagesize:     2048 kB
> > 
> > Greg, do you see any obvious violations of sysfs rules here? Well, beyond
> > meminfo itself, I guess, but given our previous snapshot discussion, I left it
> > simple and the same, rather than split it up.
> 
> Yeah, I don't like that file.  Why not just have 5 files, one for each
> value?  There isn't such a need for an immediate snapshot shere you
> can't just read all 5 values from 5 files?

Actually, we already have Total in nr_hugepages, so I only needed to add
3 files. The size is implicit in the directory name?

> Also, why use a "units" here, just always use the lowest unit, and
> userspace can convert from kB to GB if needed.

Agreed, so I changed the name of the directory from

hugepages-2M

to

hugpeages-2048

for instance. Userspace utilities can pretty-ize it :)

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
