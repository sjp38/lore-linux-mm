Subject: Re: [RFC] RSS guarantees and limits
References: <Pine.LNX.4.21.0006221834530.1137-100000@duckman.distro.conectiva>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 22 Jun 2000 23:48:18 +0100
In-Reply-To: Rik van Riel's message of "Thu, 22 Jun 2000 18:37:58 -0300 (BRST)"
Message-ID: <m2itv19vt9.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> Also, the memory space used by these small apps is usually
> negligable compared to the memory used by the big program.
> 
> What is 2% memory use for the big program can be the difference
> between running and crawling for something like bash...

I agree that this is usually true. But that is only because the big
program actually isn't using the memory; in that case the memory
should be freed anyway. If a big program were to actually use all its
memory, then this system would destroy its performance, as all the
getty's on the system and silly luser tweaks which aren't actually
being used at all would take away useful memory.

I booted up with mem=8M today, and found that even small things like
bash were about 20% of system ram. By not letting a single big process
(about the biggest that'd fit was emacs) get most all of the memory
from the various junk that wasn't being used, the system would be
completely unusable rather than merely a little slow.

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
