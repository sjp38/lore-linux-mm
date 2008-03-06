Subject: Re: [BUG] 2.6.25-rc4 hang/softlockups after freeing hugepages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080306174520.GA29047@elte.hu>
References: <1204824183.5294.62.camel@localhost>
	 <20080306174520.GA29047@elte.hu>
Content-Type: text/plain
Date: Thu, 06 Mar 2008 13:19:13 -0500
Message-Id: <1204827553.5294.80.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Adam Litke <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-03-06 at 18:45 +0100, Ingo Molnar wrote:
> * Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > Test platform: HP Proliant DL585 server - 4 socket, dual core AMD with 
> > 32GB memory.
> 
> does the patch below change the problem in any way? (it fixes a rare 
> hugetlbfs related memory leak)

I'll try it.  I didn't actually fault in any hugepages in my last test,
so I wouldn't have expected page tables to be involved.  I'll let you
know.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
