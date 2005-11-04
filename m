Date: Thu, 3 Nov 2005 23:26:49 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051103232649.12e58615.pj@sgi.com>
In-Reply-To: <20051104063820.GA19505@elte.hu>
References: <20051104010021.4180A184531@thermo.lanl.gov>
	<Pine.LNX.4.64.0511032105110.27915@g5.osdl.org>
	<20051103221037.33ae0f53.pj@sgi.com>
	<20051104063820.GA19505@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: torvalds@osdl.org, andy@thermo.lanl.gov, mbligh@mbligh.org, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Ingo wrote:
> to clearly stress the 'might easily fail' restriction. But if userspace 
> is well-behaved on Andy's systems (which it seems to be), then in 
> practice it should be resizable. 

At first glance, this is the sticky point that jumps out at me.

Andy wrote:
>    My experience is that after some days or weeks of running have gone
>    by, there is no possible way short of a reboot to get pages merged
>    effectively back to any pristine state with the infrastructure that 
>    exists there.

I take it, from what Andy writes, and from my other experience with
similar customers, that his workload is not "well-behaved" in the
sense you hoped for.

After several diverse jobs are run, we cannot, so far as I know,
merge small pages back to big pages.

I have not played with Mel Gorman's Fragmentation Avoidance patches,
so don't know if they would provide a substantial improvement here.
They well might.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
