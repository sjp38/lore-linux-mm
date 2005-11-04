Message-ID: <436B1150.2010001@cosmosbay.com>
Date: Fri, 04 Nov 2005 08:44:16 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051104010021.4180A184531@thermo.lanl.gov>	<Pine.LNX.4.64.0511032105110.27915@g5.osdl.org> <20051103221037.33ae0f53.pj@sgi.com>
In-Reply-To: <20051103221037.33ae0f53.pj@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, andy@thermo.lanl.gov, mbligh@mbligh.org, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Paul Jackson a ecrit :
> Linus wrote:
> 
>>Maybe you'd be willing on compromising by using a few kernel boot-time 
>>command line options for your not-very-common load.
> 
> 
> If we were only a few options away from running Andy's varying load
> mix with something close to ideal performance, we'd be in fat city,
> and Andy would never have been driven to write that rant.

I found hugetlb support in linux not very practical/usable on NUMA machines, 
boot-time parameters or /proc/sys/vm/nr_hugepages.

With this single integer parameter, you cannot allocate 1000 4MB pages on one 
specific node, letting small pages on another node.

I'm not an astrophysician, nor a DB admin, I'm only trying to partition a dual 
node machine between one (numa aware) memory intensive job and all others 
(system, network, shells).
At least I can reboot it if needed, but I feel Andy pain.

There is a /proc/buddyinfo file, maybe we need a /proc/sys/vm/node_hugepages 
with a list of integers (one per node) ?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
