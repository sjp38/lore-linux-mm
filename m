Date: Tue, 9 Feb 1999 22:57:51 GMT
Message-Id: <199902092257.WAA05676@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Large memory system
In-Reply-To: <m17lts52v4.fsf@flinx.ccr.net>
References: <19990130083631.B9427@msc.cornell.edu>
	<Pine.LNX.3.95.990130114256.27443A-100000@kanga.kvack.org>
	<199902081124.LAA02285@dax.scot.redhat.com>
	<m17lts52v4.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Daniel Blakeley <daniel@msc.cornell.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 08 Feb 1999 09:31:11 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

> Cool.  We now have an idea that sounds possible.

> The only remaining question is how much of a performance hit would
> changing the contents of a pte around all of the time be?

Very little: there's the cost of the page invalidate (a couple of
cycles), plus the cost of the CPU refilling that tlb from the page
tables.  It's completely lost in the noise compared to the cost of
transferring an entire page of data to/from user space.

> Every single page read/write syscall, as well as copying down to I/O
> bounce buffers sounds common enough that we probably would see a
> performance hit.

I doubt that it would be measurable.

> The other thing that happens is we start breaking assumptions about
> fixed limits based on architecture size.  Things like the swap entry
> may need to be expanded.

The swap entry can probably stay completely independent; most people
with 8G of ram are going to be trying hard never to hit swap anyway. :)
Besides, we already have support for 16G of swap as things stand.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
