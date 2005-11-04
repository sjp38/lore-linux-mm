From: Andi Kleen <ak@suse.de>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Date: Fri, 4 Nov 2005 23:43:27 +0100
References: <20051104201248.GA14201@elte.hu> <20051104210418.BC56F184739@thermo.lanl.gov> <e692861c0511041331ge5dd1abq57b6c513540fa200@mail.gmail.com>
In-Reply-To: <e692861c0511041331ge5dd1abq57b6c513540fa200@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511042343.27832.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gregory Maxwell <gmaxwell@gmail.com>
Cc: Andy Nelson <andy@thermo.lanl.gov>, mingo@elte.hu, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Friday 04 November 2005 22:31, Gregory Maxwell wrote:
> On 11/4/05, Andy Nelson <andy@thermo.lanl.gov> wrote:
> > I am not enough of a kernel level person or sysadmin to know for certain,
> > but I have still big worries about consecutive jobs that run on the
> > same resources, but want extremely different page behavior. I
>
> Thats the idea. The 'hugetlb zone' will only be usable for allocations
> which are guaranteed reclaimable.  Reclaimable includes userspace
> usage (since at worst an in use userspace page can be swapped out then
> paged back into another physical location).

I don't like it very much. You have two choices if a workload runs
out of the kernel allocatable pages. Either you spill into the reclaimable
zone or you fail the allocation. The first means that the huge pages
thing is unreliable, the second would mean that all the many problems
of limited lowmem would be back.

None of this is very attractive.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
