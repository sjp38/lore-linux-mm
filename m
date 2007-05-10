Date: Thu, 10 May 2007 11:04:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory hotremove patch take 2 [02/10] (make page unused)
In-Reply-To: <20070509120248.B908.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705101101460.10002@schroedinger.engr.sgi.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
 <20070509120248.B908.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Yasunori Goto wrote:

> This patch is for supporting making page unused.
> 
> Isolate pages by capturing freed pages before inserting free_area[],
> buddy allocator.
> If you have an idea for avoiding spin_lock(), please advise me.

Using the zone lock instead may avoid to introduce another lock? Or is the 
new lock here for performance reasons?

Isnt it possible to just add another flavor of pages like what Mel has 
been doing with reclaimable and movable? I.e. add another category of free 
pages to Mel's scheme called isolated and use Mel's function to move stuff 
over there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
