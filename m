Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0284E6B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 03:33:20 -0400 (EDT)
Message-ID: <4FB357C9.8080308@parallels.com>
Date: Wed, 16 May 2012 11:31:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] SL[AUO]B common code 1/9] [slob] define page struct fields
 used in mm_types.h
References: <20120514201544.334122849@linux.com> <20120514201609.418025254@linux.com>
In-Reply-To: <20120514201609.418025254@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On 05/15/2012 12:15 AM, Christoph Lameter wrote:
> - * We use struct page fields to manage some slob allocation aspects,
> - * however to avoid the horrible mess in include/linux/mm_types.h, we'll
> - * just define our own struct page type variant here.
> - */
> -struct slob_page {
> -	union {
> -		struct {
> -			unsigned long flags;	/* mandatory */
> -			atomic_t _count;	/* mandatory */
> -			slobidx_t units;	/* free units left in page */
> -			unsigned long pad[2];
> -			slob_t *free;		/* first free slob_t in page */
> -			struct list_head list;	/* linked list of free pages */
> -		};
> -		struct page page;
> -	};
> -};

I am generally in favor of this, but since this list inside the 
structure doesn't seem to have any particular order, I think it should 
not be called LRU.

It is of course ok to reuse the field, but what about we make it a union 
between "list" and "lru" ?

It may seem stupid because they all have the same storage size, but the 
word "lru" does trigger a lot of assumptions on people reading the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
