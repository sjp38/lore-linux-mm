Date: Mon, 22 Nov 2004 14:40:39 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: deferred rss update instead of sloppy rss
In-Reply-To: <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 22 Nov 2004, Christoph Lameter wrote:
> 
> I think the approach that I posted is simpler unless there are other
> benefits to be gained if it would be easy to figure out which tasks use an
> mm.

I'm just worried that your timer tick thing won't catch things in a timely 
manner. That said, if that isn't an issue, and people don't have problems 
with it. On the other hand, if /proc literally is the only real user, then 
I guess it really can't matter.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
