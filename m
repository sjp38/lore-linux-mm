Date: Wed, 2 Oct 2002 11:27:41 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: my VM TODO list
In-Reply-To: <20021002100015.GC31587@holomorphy.com>
Message-ID: <Pine.LNX.4.44L.0210021126590.22735-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Oct 2002, William Lee Irwin III wrote:

> (2) pagetable reclaim
> 	Figured out where the pmd weirdness happens and restarted
> 	lookups, need to find a spot to go blow them away, when
> 	to do it, and maybe do something about private anonymous.
>
> (3) help out with pagetable sharing
> 	Not sure what's going on there.

I'm willing to help out with both of these.   Is there any current
code around I could take a look at and work from ?

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
