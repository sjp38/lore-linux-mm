Message-ID: <45B9ED45.5090002@yahoo.com.au>
Date: Fri, 26 Jan 2007 23:00:05 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Track mlock()ed pages
References: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>	<45B9A00C.4040701@yahoo.com.au>	<Pine.LNX.4.64.0701252234490.11230@schroedinger.engr.sgi.com> <20070126031300.59f75b06.akpm@osdl.org>
In-Reply-To: <20070126031300.59f75b06.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 25 Jan 2007 22:36:17 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 

>>>I can't think of an easy way to do this without per-page state. ie.
>>>another page flag.
>>
>>Thats what I am trying to avoid.
> 
> 
> You could perhaps go for a walk across all the other vmas which presently
> map this page.  If any of them have VM_LOCKED, don't increment the counter.
> Similar on removal: only decrement the counter when the final mlocked VMA
> is dropping the pte.

Can't do with un-racily because you can't get that information
atomically, AFAIKS. When / if we ever lock the page in fault handler,
this could become easier... but that seems nasty to do in fault path,
even if only for VM_LOCKED vmas.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
