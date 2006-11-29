Message-ID: <456D1D82.3060001@yahoo.com.au>
Date: Wed, 29 Nov 2006 16:41:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Slab: Remove kmem_cache_t
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>	<456D0757.6050903@yahoo.com.au>	<Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>	<456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org>
In-Reply-To: <20061128200619.67080e11.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 29 Nov 2006 15:42:44 +1100
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>So what exactly is wrong with
>>a kmem_cache_t declaration in include files, then?
> 
> 
> a) it's a typedef and
> 
> b) it's a typedef, and you cannot forward-declare typedefs.  We've hit this
>    a couple of times.  Header files need to include slab.h just to be able to do
> 
> 	extern kmem_cache_t *wozzle;

So why doesn't

   typedef struct kmem_cache kmem_cache_t;
   extern kmem_cache_t *wozzle;

work?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
