Date: Fri, 2 Aug 2002 09:52:19 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: large page patch
In-Reply-To: <200208020205.47308.ryan@completely.kicks-ass.org>
Message-ID: <Pine.LNX.4.44L.0208020951360.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ryan Cumming <ryan@completely.kicks-ass.org>
Cc: "David S. Miller" <davem@redhat.com>, davidm@hpl.hp.com, davidm@napali.hpl.hp.com, gh@us.ibm.com, akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 2 Aug 2002, Ryan Cumming wrote:
> On August 2, 2002 01:20, David S. Miller wrote:

> > A "hint" to use superpages?  That's absurd.
>
> What about applications that want fine-grained page aging? 4MB is a tad
> on the course side for most desktop applications.

Of course we wouldn't want to use superpages for VMAs smaller
than, say, 4 of these superpages.

That would fix this problem automagically.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
