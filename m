Date: Sat, 5 Jul 2003 14:27:52 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.5.74-mm1
Message-Id: <20030705142752.37a3566a.akpm@osdl.org>
In-Reply-To: <20030705211740.GA15452@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org>
	<20030704210737.GI955@holomorphy.com>
	<20030704181539.2be0762a.akpm@osdl.org>
	<20030705104433.GK955@holomorphy.com>
	<20030705114308.6dacb5a2.akpm@osdl.org>
	<20030705211740.GA15452@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: anton@samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
> On Sat, Jul 05, 2003 at 11:43:08AM -0700, Andrew Morton wrote:
> > if badness() returns zero for everything, this returns NULL and
> > the kernel panics.
> 
> Sorry, that was one hell of an oversight wrt. the initival value.

You made me read that code about 20 times ;)

Still.  Do we think we know what the actual bug is?  That tasklist_lock
doesn't pin tsk->mm?

If so then let's get that patch of yours happening, but please enhance it to

a) detect the situation where the mm went away, and tell us that it was
   fixed up.  Sufficient to confirm your theory.

b) put in an explicit check for a kill of an mm-less process.  print a
   warning, skip the process.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
