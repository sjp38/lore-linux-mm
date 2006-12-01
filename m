Received: by ug-out-1314.google.com with SMTP id s2so2107052uge
        for <linux-mm@kvack.org>; Fri, 01 Dec 2006 02:00:53 -0800 (PST)
Message-ID: <6d6a94c50612010200t2c9dfc36m603ddc4948285bf@mail.gmail.com>
Date: Fri, 1 Dec 2006 18:00:53 +0800
From: Aubrey <aubreylee@gmail.com>
Subject: Re: The VFS cache is not freed when there is not enough free memory to allocate
In-Reply-To: <456F4A95.2090503@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>
	 <1164185036.5968.179.camel@twins>
	 <6d6a94c50611220202t1d076b4cye70dcdcc19f56e55@mail.gmail.com>
	 <456A964D.2050004@yahoo.com.au>
	 <4e5ebad50611282317r55c22228qa5333306ccfff28e@mail.gmail.com>
	 <6d6a94c50611290127u2b26976en1100217a69d651c0@mail.gmail.com>
	 <456D5347.3000208@yahoo.com.au>
	 <6d6a94c50611300454g22196d2frec54e701abaebf17@mail.gmail.com>
	 <456F4A95.2090503@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Sonic Zhang <sonic.adi@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vapier.adi@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/1/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> The pattern you are seeing here is probably due to the page allocator
> always retrying process context allocations which are <= order 3 (64K
> with 4K pages).
>
> You might be able to increase this limit a bit for your system, but it
> could easily cause problems. Especially fragmentation on nommu systems
> where the anonymous memory cannot be paged out.

Thanks for your clue. I found increasing this limit could really help
my test cases.
When MemFree < 8M, and the test case request 1M * 8 times, the
allocation can be sucessful after 81 times rebalance, :). So far I
haven't found any issue.

If I make a patch to move this parameter to be tunable in the proc
filesystem on nommu case, is it acceptable?

Thanks,
-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
