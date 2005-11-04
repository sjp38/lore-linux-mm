Date: Fri, 04 Nov 2005 08:13:28 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <331390000.1131120808@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.64.0511040738540.27915@g5.osdl.org>
References: <20051104145628.90DC71845CE@thermo.lanl.gov> <Pine.LNX.4.64.0511040738540.27915@g5.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>, Andy Nelson <andy@thermo.lanl.gov>
Cc: akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> So I suspect Martin's 25% is a lot more accurate on modern hardware (which 
> means x86, possibly Power. Nothing else much matters).

It was PPC64, if that helps.
 
>> If your and other kernel developer's (<<0.01% of the universe) kernel
>> builds slow down by 5% and my and other people's simulations (perhaps 
>> 0.01% of the universe) speed up by a factor up to 3 or 4, who wins? 
> 
> First off, you won't speed up by a factor of three or four. Not even 
> _close_. 

Well, I think it depends on the workload a lot. However fast your TLB is,
if we move from "every cacheline read requires is a TLB miss" to "every
cacheline read is a TLB hit" that can be a huge performance knee however
fast your TLB is. Depends heavily on the locality of reference and size
of data set of the application, I suspect.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
