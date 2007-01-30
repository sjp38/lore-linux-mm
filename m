Message-ID: <45BEA73C.5030809@yahoo.com.au>
Date: Tue, 30 Jan 2007 13:02:36 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
References: <1169993494.10987.23.camel@lappy> <20070128142925.df2f4dce.akpm@osdl.org> <20070129190806.GA14353@elte.hu>
In-Reply-To: <20070129190806.GA14353@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:

> For every 64-bit Fedora box there's more than seven 32-bit boxes. I 
> think 32-bit is going to live with us far longer than many thought, so 
> we might as well make it work better. Both HIGHMEM and HIGHPTE is the 
> default on many distro kernels, which pushes the kmap infrastructure 
> quite a bit.

I don't think anybody would argue against numbers, but just that there
are not many big 32-bit SMPs anymore. And if Bill Irwin didn't fix the
kmap problem back then, it would be interesting to see a system and
workload where it actually is a bottleneck.

Not that I'm against any patch to improve scalability, if it doesn't
hurt single-threaded performance ;)

> the problem is that everything that was easy to migrate was migrated off 
> kmap() already - and it's exactly those hard cases that cannot be 
> converted (like the pagecache use) which is the most frequent kmap() 
> users.

Which pagecache use? file_read_actor()?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
