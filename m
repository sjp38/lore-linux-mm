From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14301.23957.990042.692273@dukat.scot.redhat.com>
Date: Mon, 13 Sep 1999 21:24:53 +0100 (BST)
Subject: Re: bdflush defaults bugreport
In-Reply-To: <Pine.LNX.3.96.990913140636.29128A-100000@kanga.kvack.org>
References: <14301.15443.303167.898233@dukat.scot.redhat.com>
	<Pine.LNX.3.96.990913140636.29128A-100000@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 13 Sep 1999 14:11:36 -0400 (EDT), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> I'm not quite sure if you caught my original response to Rik, but the
> problem seems to stem from the fact that bdflush is waking users without
> checking if the % dirty buffers is low enough.  Just moving the wakeup a
> couple of lines down looks like a solution (although I can't say for
> certain that the performance effects won't be dreadful).

I'm not sure if you caught my other response, but moving that wakeup one
line down will just result in the writing task being able to write one
more block before blocking on bdflush yet again.

> There's another problem with 2.2.10+: by limiting to the percentage of
> dirty buffers, behaviour on temp files/with lots of free ram is ugly.  I'm
> wondering if limiting according to % memory dirty instead would be
> reasonable -- your thoughts?

Close.  The real solution is probably to reserve a %age of memory to be
clean.  In other words the limit shouldn't just be on dirty memory, it
should be on dirty pages plus non-movable pages (kmalloc etc).  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
