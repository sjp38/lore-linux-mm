Date: Sat, 9 Jun 2007 17:27:18 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 04 of 16] serialize oom killer
Message-ID: <20070609152718.GD7130@v2.random>
References: <baa866fedc79cb333b90.1181332982@v2.random> <1181371427.7348.293.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181371427.7348.293.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 09, 2007 at 08:43:47AM +0200, Peter Zijlstra wrote:
> On Fri, 2007-06-08 at 22:03 +0200, Andrea Arcangeli wrote:
> > +	static DECLARE_MUTEX(OOM_lock);
> 
> I thought we depricated that construct in favour of DEFINE_MUTEX. Also,

Ok, so it should be changed to DEFINE_MUTEX. I have to trust you on
this because there's not a sign of warning in asm-i386/semaphore.h
that DECLARE_MUTEX has been deprecated and tons of code is still using
it in the current kernel. I couldn't imagine that somebody duplicated
it somewhere else for whatever reason without removing
DECLARE_MUTEX. It's not like we have to keep deprecated and redundant
interfaces in the kernel for no good reason, especially if `sed` can
fix it without human intervention. Let's say it's a low priority to
rename it, if I've to generate a new diff, I'd probably prefer to
generate one that drops DECLARE_MUTEX all over the other places too.

> putting it in a function like so is a little icky IMHO.

On this I disagree, the whole point of static/private variables is to
decrease visibility where it's unnecessary. A static variable
function-local is even less visible so it's a good thing and it helps
self-documenting the code. So I very much like to keep it there,
coding strict improves readability (you immediately know that no other
code could ever try to acquire that lock).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
