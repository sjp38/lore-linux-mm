Date: Mon, 28 Apr 2008 14:29:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
 [Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI]
In-Reply-To: <20080428205200.GA4386@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0804281427150.32083@schroedinger.engr.sgi.com>
References: <20080417231617.GA18815@us.ibm.com>
 <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
 <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com>
 <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com>
 <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com>
 <20080427051029.GA22858@suse.de> <Pine.LNX.4.64.0804281328300.31163@schroedinger.engr.sgi.com>
 <20080428205200.GA4386@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Greg KH <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Apr 2008, Nishanth Aravamudan wrote:

> More importnatly, I think the fact that IA64 supports multiple hugepage
> sizes is a reason *for* moving to sysfs for this information? However, I
> think we may need to massage the IA64-specific bits of the kernel to
> actually support multiple hugepage size pools being available at
> run-time? That is, with the current kernel, we can only support one
> hugepagesize at run-time, due to VHPT restrictions?

We'd love to have multiple huge page pools available but the current rigid 
region setup limits us to one size. Switching off the VHPT or doing some 
tricks with the tlb fault handler, or freeing up an unused region (region 
0?) could get us there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
