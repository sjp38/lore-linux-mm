Date: Fri, 6 Sep 2002 05:51:29 -0700 (PDT)
From: "M. Edward (Ed) Borasky" <znmeb@aracnet.com>
Subject: Re: meminfo or Rephrased helping the Programmer's help themselves...
In-Reply-To: <Pine.LNX.4.44.0209061810020.17303-100000@parore>
Message-ID: <Pine.LNX.4.44.0209060533440.23212-100000@shell1.aracnet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Carter <john.carter@tait.co.nz>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, John Carter wrote:

> The http://www.faqs.org/faqs/unix-faq/programmer/faq/ describes this
> nicely as a Frequently Unanswered Question...
>
> I guess Linux has been evolving but the Un*x as broad standard seems to be
> stagnating...
>
> So assuming the what the FUQ (appropriate abbreviation too) says is true,
> then my question becomes....
>
> Given that I can fudge things in userland.
>
> How would one compute an index of "Badness" from the
> information in /proc/meminfo.
>
> ie. How would my daemon, on looking at /proc/meminfo decide...
>   A) Hey, bad stuff is going down, time tell nice programs we're being
>      nibble to death.
>   B) If I grant the friendly caring program this N megabyte chunk of
>      memory, bad things will happen.

I've been looking at this sort of thing for a year and a half now. I've
begged and pleaded on the main kernel list for documentation, meaningful
performance statistics, control knobs, etc. Linux is not
enterprise-ready until it has these. I've even made a proposal; see

	http://www.borasky-research.net/Cougar.htm

I *could* devote the rest of my life to building what *I* believe is
necessary, but given the chaotic nature of the Linux development process
relative to, say, SEI level 2, I'm reluctant to devote what little
sanity I have left to jousting this particular windmill. There are too
many other fun things in life, many of which you'll find on my main web
site.

As to what constitutes "badness", that depends entirely on what the
computer in question is doing to earn its keep. If it's a web server,
the real measures of goodness or badness are things you measure with a
web performance tool like Segue SilkPerformer. If it's an engineering
workstation, it has to be able to do big scientific/graphic calculations
while not impeding the flow of e-mail, documentation, etc. in the
organization where the engineer works.

So, getting back to your theme ... what does the computer you're
attempting to manage do for a living? What are the cost tradeoffs
between your programming time and buying more RAM? Do you have all of
the memory leaks out of your code?
-- 
M. Edward Borasky
znmeb@borasky-research.net

The COUGAR Project
http://www.borasky-research.com/Cougar.htm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
