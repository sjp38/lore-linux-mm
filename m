Date: Fri, 6 Sep 2002 10:12:18 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: meminfo or Rephrased helping the Programmer's help themselves...
In-Reply-To: <Pine.LNX.4.44.0209060533440.23212-100000@shell1.aracnet.com>
Message-ID: <Pine.LNX.4.44L.0209061010190.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "M. Edward (Ed) Borasky" <znmeb@aracnet.com>
Cc: John Carter <john.carter@tait.co.nz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, M. Edward (Ed) Borasky wrote:

> I've been looking at this sort of thing for a year and a half now. I've
> begged and pleaded on the main kernel list for documentation, meaningful
> performance statistics, control knobs, etc. Linux is not
> enterprise-ready until it has these. I've even made a proposal; see
>
> 	http://www.borasky-research.net/Cougar.htm

That's a _very_ high overview proposal.  A good start would be
defining what statistics are missing from the kernel and how
exactly you'd want to collect those.

> I *could* devote the rest of my life to building what *I* believe is
> necessary, but given the chaotic nature of the Linux development process
> relative to, say, SEI level 2, I'm reluctant to devote what little
> sanity I have left to jousting this particular windmill.

One step at a time.  It _is_ possible to put better statistics
into the Linux kernel, as long as they are sent in in manageable
chunks.

Speaking of which, I need to resubmit my iowait statistics patch.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
