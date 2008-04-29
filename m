Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3TGhZ3n003388
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 12:43:35 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3TGhZcm334964
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 12:43:35 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3TGhYxm012980
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 12:43:34 -0400
Date: Tue, 29 Apr 2008 09:43:32 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080429164332.GA24967@us.ibm.com>
References: <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com> <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com> <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <Pine.LNX.4.64.0804281328300.31163@schroedinger.engr.sgi.com> <20080428205200.GA4386@us.ibm.com> <Pine.LNX.4.64.0804281427150.32083@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804281427150.32083@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Greg KH <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.04.2008 [14:29:02 -0700], Christoph Lameter wrote:
> On Mon, 28 Apr 2008, Nishanth Aravamudan wrote:
> 
> > More importnatly, I think the fact that IA64 supports multiple hugepage
> > sizes is a reason *for* moving to sysfs for this information? However, I
> > think we may need to massage the IA64-specific bits of the kernel to
> > actually support multiple hugepage size pools being available at
> > run-time? That is, with the current kernel, we can only support one
> > hugepagesize at run-time, due to VHPT restrictions?
> 
> We'd love to have multiple huge page pools available but the current
> rigid region setup limits us to one size. Switching off the VHPT or
> doing some tricks with the tlb fault handler, or freeing up an unused
> region (region 0?) could get us there.

Ok, that was my impression. So on IA64, without further kernel
modifications, we will always only have one hugepage size visible in
/proc/meminfo and /sys/kernel/hugepages?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
