Date: Mon, 1 Oct 2001 10:57:05 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Load control  (was: Re: 2.4.9-ac16 good perfomer?)
In-Reply-To: <20011001111435Z16281-2757+2605@humbolt.nl.linux.org>
Message-ID: <Pine.LNX.4.33L.0110011031050.4835-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Mike Fedyk <mfedyk@matchmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Oct 2001, Daniel Phillips wrote:

> Nice.  With this under control, another feature of his memory manager
> you could look at is the variable deactivation threshold, which makes
> a whole lot more sense now that the aging is linear.

Actually, when we get to the point where deactivating enough
pages is hard, we know the working set is large and we should
be _more careful_ in chosing what to page out...

When we go one step further, where the working set approaches
the size of physical memory, we should probably start doing
load control FreeBSD-style ... pick a process and deactivate
as many of its pages as possible. By introducing unfairness
like this we'll be sure that only one or two processes will
slow down on the next VM load spike, instead of all processes.

Once we reach permanent heavy overload, we should start doing
process scheduling, restricting the active processes to a
subset of all processes in such a way that the active processes
are able to make progress. After a while, give other processes
their chance to run.

regards,

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
