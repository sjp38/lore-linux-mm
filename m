Date: Sat, 20 Jul 2002 16:09:46 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] for_each_pgdat
Message-ID: <20020720230946.GH1096@holomorphy.com>
References: <1027201039.1085.812.camel@sinai> <244469929.1027180137@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <244469929.1027180137@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Robert Love <rml@tech9.net>, Linus Torvalds <torvalds@transmeta.com>, akpm@zip.com.au, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At some point in the past, Robert Love wrote:
>> If Bill wants to convert pgdats to lists that is fine but is another
>> step.  Let's get in this first batch and that can be done off this.

On Sat, Jul 20, 2002 at 03:48:59PM -0700, Martin J. Bligh wrote:
> As we now reference them in only two places (the macro defn and
> numa.c:_alloc_pages) it hardly seems worth converting to lists ... ? 
> (I'm going to take an axe to NUMA _alloc_pages in a minute anyway ;-))

I won't stand in the way of any of this, the list.h sort-of suggestion
was merely part of questioning the pgdat_next change. In fact, it was
meant more to point out what you just did, that the iterator takes the
field out of direct usage except for a couple of places.

I'll stand behind these changes as they are now.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
