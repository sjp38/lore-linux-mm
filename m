Message-ID: <456E472D.4060300@yahoo.com.au>
Date: Thu, 30 Nov 2006 13:51:25 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Slab: Remove kmem_cache_t
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com> <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com> <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org> <Pine.LNX.4.64.0611282027431.3395@woody.osdl.org> <456D1FDA.4040201@yahoo.com.au> <Pine.LNX.4.64.0611290738270.3395@woody.osdl.org> <456E36A7.2050401@yahoo.com.au> <Pine.LNX.4.64.0611291755310.3513@woody.osdl.org> <456E3E98.5010706@yahoo.com.au> <Pine.LNX.4.64.0611291822420.3513@woody.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611291822420.3513@woody.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

[stuff]

Thanks, makes sense.

> This particular one doesn't disturb me the way some have done. I literally 
> asked for the "task_t" typedef to be removed (ugh, that one _really_ 
> irritated me, especially since code mixed the two, and "struct 
> task_struct" was the traditional and long-standing way to do it).

I agree task_t was horrible, especially as it was being used in
places like sched.c that actually accessed fields in the structure.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
