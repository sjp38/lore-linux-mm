Date: Sun, 06 Apr 2003 15:25:08 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: subobj-rmap
Message-ID: <2640000.1049667906@[10.10.2.4]>
In-Reply-To: <20030406221547.GP1326@dualathlon.random>
References: <Pine.LNX.4.44.0304061737510.2296-100000@chimarrao.boston.redhat.com> <1600000.1049666582@[10.10.2.4]> <20030406221547.GP1326@dualathlon.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@surriel.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Bill Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

>> We can always leave the sys_remap_file_pages stuff using pte_chains,
> 
> not sure why you want still to have the vm to know about the
> mmap(VM_NONLINEAR) hack at all.
> 
> that's a vm bypass. I can bet the people who wants to use it for running
> faster on the the 32bit archs will definitely prefer zero overhead and
> full hardware speed with only the pagetable and tlb flushing trash, and
> zero additional kernel internal overhead. that's just a vm bypass that
> could otherwise sit in kernel module, not a real kernel API.

Well, you don't get zero overhead whatever you do. You either pay the
cost at remap time of manipulating sub-objects, or the cost at page-touch
time of the pte_chains stuff. I suspect sub-objects are cheaper if we
read /write the 32K chunks, not if people mostly just touch one page
per remap though.

What do you think about using this for the linear stuff though?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
