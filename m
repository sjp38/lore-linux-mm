Date: Mon, 22 Nov 2004 14:22:30 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: deferred rss update instead of sloppy rss
In-Reply-To: <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 22 Nov 2004, Christoph Lameter wrote:
> 
> The problem is then that the proc filesystem must do an extensive scan
> over all threads to find users of a certain mm_struct.

The alternative is to just add a simple list into the task_struct and the
head of it into mm_struct. Then, at fork, you just finish the fork() with

	list_add(p->mm_list, p->mm->thread_list);

and do the proper list_del() in exit_mm() or wherever.

You'll still loop in /proc, but you'll do the minimal loop necessary.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
