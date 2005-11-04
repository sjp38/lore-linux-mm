Date: Fri, 4 Nov 2005 22:14:19 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051104211419.GA15888@elte.hu>
References: <20051104201248.GA14201@elte.hu> <20051104210418.BC56F184739@thermo.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051104210418.BC56F184739@thermo.lanl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Nelson <andy@thermo.lanl.gov>
Cc: pj@sgi.com, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

* Andy Nelson <andy@thermo.lanl.gov> wrote:

>   5) How does any of this stuff play with me having to rewrite my code to
>      use nonstandard language features? If I can't run using standard 
>      fortran, standard C and maybe for some folks standard C++ or Java,
>      it won't fly. 

it ought to be possible to get pretty much the same API as hugetlbfs via 
the 'hugetlb zone' approach too. It doesnt really change the API and FS 
side, it only impacts the allocator internally. So if you can utilize 
hugetlbfs, you should be able to utilize a 'special zone' approach 
pretty much the same way.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
