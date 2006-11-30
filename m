Message-ID: <456E36A7.2050401@yahoo.com.au>
Date: Thu, 30 Nov 2006 12:40:55 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Slab: Remove kmem_cache_t
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com> <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com> <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org> <Pine.LNX.4.64.0611282027431.3395@woody.osdl.org> <456D1FDA.4040201@yahoo.com.au> <Pine.LNX.4.64.0611290738270.3395@woody.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611290738270.3395@woody.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Wed, 29 Nov 2006, Nick Piggin wrote:
> 
>>I don't see why pagetable types are conceptually different from slab here.
> 
> 
> Because they are fundamentally _different_ on different architectures.

So is struct kmem_cache for slab vs slob.


> If they were always the same, they wouldn't be typedefs.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
