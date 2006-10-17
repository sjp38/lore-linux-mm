Date: Mon, 16 Oct 2006 18:25:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Oct 2006, KAMEZAWA Hiroyuki wrote:

> How about defining following instead of inserting #ifdefs ?
> 
> #ifdef ZONES_SHIFT > 0
> #define zone_lowmem_reserve(z, i)	((z)->lowmem_reserve[(i)])
> #else
> #define zone_lowmem_reserve(z, i)	(0)
> #endif
> 
> and removing #if's from *.c files ? Can't this be help ?

Well it only shifts the #ifdef elsewhere.... 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
