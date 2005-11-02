Date: Wed, 2 Nov 2005 11:41:31 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051102104131.GA7780@elte.hu>
References: <20051102071943.GA1574@elte.hu> <E1EXDKN-0004b9-00@w-gerrit.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1EXDKN-0004b9-00@w-gerrit.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

* Gerrit Huizenga <gh@us.ibm.com> wrote:

> > generic unpluggable kernel RAM _will not work_.
> 
> Actually, it will.  Well, depending on terminology.

'generic unpluggable kernel RAM' means what it says: any RAM seen by the 
kernel can be unplugged, always. (as long as the unplug request is 
reasonable and there is enough free space to migrate in-use pages to).

> There are two usage models here - those which intend to remove 
> physical elements and those where the kernel returnss management of 
> its virtualized "physical" memory to a hypervisor.  In the latter 
> case, a hypervisor already maintains a virtual map of the memory and 
> the OS needs to release virtualized "physical" memory.  I think you 
> are referring to RAM here as the physical component; however these 
> same defrag patches help where a hypervisor is maintaining the real 
> physical memory below the operating system and the OS is managing a 
> virtualized "physical" memory.

reliable unmapping of "generic kernel RAM" is not possible even in a 
virtualized environment. Think of the 'live pointers' problem i outlined 
in an earlier mail in this thread today.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
