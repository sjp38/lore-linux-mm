Date: Sat, 20 Jul 2002 15:48:59 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: [PATCH] for_each_pgdat
Message-ID: <244469929.1027180137@[10.10.2.3]>
In-Reply-To: <1027201039.1085.812.camel@sinai>
References: <1027201039.1085.812.camel@sinai>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>, Linus Torvalds <torvalds@transmeta.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, akpm@zip.com.au, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Ok guys, you three (and whoever else wants to play? ;) fight it out amonst
>> yourselves, I'll wait for the end result (iow: I'll just ignore both
>> patches for now).
> 
> No no... the issues are fairly orthogonal.
> 
> Attached is a patch with the for_each_pgdat implementation and
> s/node_next/pgdat_next/ per Martin.

I'm happy with this (obviously ;-))
 
> If Bill wants to convert pgdats to lists that is fine but is another
> step.  Let's get in this first batch and that can be done off this.

As we now reference them in only two places (the macro defn and
numa.c:_alloc_pages) it hardly seems worth converting to lists ... ? 
(I'm going to take an axe to NUMA _alloc_pages in a minute anyway ;-))

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
