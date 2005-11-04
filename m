Received: by xproxy.gmail.com with SMTP id h31so576624wxd
        for <linux-mm@kvack.org>; Fri, 04 Nov 2005 13:31:23 -0800 (PST)
Message-ID: <e692861c0511041331ge5dd1abq57b6c513540fa200@mail.gmail.com>
Date: Fri, 4 Nov 2005 16:31:23 -0500
From: Gregory Maxwell <gmaxwell@gmail.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <20051104210418.BC56F184739@thermo.lanl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051104201248.GA14201@elte.hu>
	 <20051104210418.BC56F184739@thermo.lanl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Nelson <andy@thermo.lanl.gov>
Cc: mingo@elte.hu, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/4/05, Andy Nelson <andy@thermo.lanl.gov> wrote:
> I am not enough of a kernel level person or sysadmin to know for certain,
> but I have still big worries about consecutive jobs that run on the
> same resources, but want extremely different page behavior. I

Thats the idea. The 'hugetlb zone' will only be usable for allocations
which are guaranteed reclaimable.  Reclaimable includes userspace
usage (since at worst an in use userspace page can be swapped out then
paged back into another physical location).

For your sort of mixed use this should be a fine solution. However
there are mixed use cases that that this will not solve, for example
if the system usage is split between HPC uses and kernel allocation
heavy workloads (say forking 10quintillion java processes) then the
hugetlb zone will need to be made small to keep the kernel allocation
heavy workload happy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
