Date: Fri, 4 Nov 2005 13:39:06 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <Pine.LNX.4.64.0511041310130.28804@g5.osdl.org>
Message-ID: <Pine.LNX.4.64.0511041333560.28804@g5.osdl.org>
References: <20051104210418.BC56F184739@thermo.lanl.gov>
 <Pine.LNX.4.64.0511041310130.28804@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Nelson <andy@thermo.lanl.gov>
Cc: mingo@elte.hu, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>


On Fri, 4 Nov 2005, Linus Torvalds wrote:
> 
> But the hint can be pretty friendly. Especially if it's an option to just 
> load a lot of memory into the boxes, and none of the loads are expected to 
> want to really be excessively close to memory limits (ie you could just 
> buy an extra 16GB to allow for "slop").

One of the issues _will_ be how to allocate things on NUMA. Right now 
"hugetlb" only allows us to say "this much memory for hugetlb", and it 
probably needs to be per-zone. 

Some uses might want to allocate all of the local memory on one node to 
huge-page usage (and specialized programs would then also like to run 
pinned to that node), others migth want to spread it out. So the 
maintenance would need to decide that.

The good news is that you can boot up with almost all zones being "big 
page" zones, and you could turn them into "normal zones" dynamically. It's 
only going the other way that is hard.

So from a maintenance standpoint if you manage lots of machines, you could 
have them all uniformly boot up with lots of memory set aside for large 
pages, and then use user-space tools to individually turn the zones into 
regular allocation zones.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
