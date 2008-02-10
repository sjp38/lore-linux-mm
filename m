Date: Sat, 9 Feb 2008 19:39:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB tbench regression due to page allocator deficiency
In-Reply-To: <20080210024517.GA32721@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080209143518.ced71a48.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
 <20080210024517.GA32721@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Sun, 10 Feb 2008, Nick Piggin wrote:

> What kind of allocating and freeing of pages are you talking about? Are
> you just measuring single threaded performance?

What I did was (on an 8p, may want to tune this to the # procs you have):

1. Run tbench_srv on console

2. run tbench 8 from an ssh session

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
