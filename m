Date: Mon, 22 Nov 2004 14:45:07 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: deferred rss update instead of sloppy rss
Message-Id: <20041122144507.484a7627.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0411221408540.22895@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
	<Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
	<20041122141148.1e6ef125.akpm@osdl.org>
	<Pine.LNX.4.58.0411221408540.22895@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: hugh@veritas.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> > just to prevent transient gross inaccuracies.  For some value of "16".
> 
> The page fault code only increments rss. For larger transactions that
> increase / decrease rss significantly the page_table_lock is taken and
> mm->rss is updated directly. So no
> gross inaccuracies can result.

Sure.  Take a million successive pagefaults and mm->rss is grossly
inaccurate.  Hence my suggestion that it be spilled into mm->rss
periodically.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
