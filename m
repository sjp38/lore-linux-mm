Date: Mon, 24 Jun 2002 18:39:51 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
In-Reply-To: <6660000.1024954471@flay>
Message-ID: <Pine.LNX.4.44L.0206241837400.18418-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Craig Kulesa <ckulesa@as.arizona.edu>, Ingo Molnar <mingo@elte.hu>, Dave Jones <davej@suse.de>, Daniel Phillips <phillips@bonn-fries.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rwhron@earthlink.net
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jun 2002, Martin J. Bligh wrote:

> A quick rough calculation indicates that the Oracle test I was helping
> out with was consuming almost 10Gb of PTEs without rmap - 30Gb for
> overhead doesn't sound like fun to me ;-(

10 GB is already bad enough that rmap isn't so much causing
a problem but increasing an already untolerable problem.

For the large SHM segment you'd probably want to either use
large pages or shared page tables ... in each of these cases
the rmap overhead will disappear together with the page table
overhead.

Now we just need volunteers for the implementation ;)

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
