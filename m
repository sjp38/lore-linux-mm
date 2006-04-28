Message-ID: <4451A290.5040508@yahoo.com.au>
Date: Fri, 28 Apr 2006 15:05:20 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: serialize OOM kill operations
References: <200604251701.31899.dsp@llnl.gov> <200604261014.15008.dsp@llnl.gov> <44503BA2.7000405@yahoo.com.au> <200604270956.15658.dsp@llnl.gov> <4451A163.5020304@yahoo.com.au>
In-Reply-To: <4451A163.5020304@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Dave Peterson <dsp@llnl.gov>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> mm_struct already has what you want -- dumpable:2 -- if you just put
> your bit in an adjacent bitfield, you'll be right.

I should have read all my email first. Ignore me ;)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
