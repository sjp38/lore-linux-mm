Date: Thu, 7 Nov 2002 11:41:56 -0500 (EST)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.46-mm1
In-Reply-To: <3DC8D423.DAD2BF1A@digeo.com>
Message-ID: <Pine.LNX.3.96.1021107113557.30525C-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Nov 2002, Andrew Morton wrote:

> 
> url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.46/2.5.46-mm1/
> 
> It wasn't clear whether it was useful or desirable to keep these patchsets
> turning over.  But it will be helpful to keep them as a marshalling point
> for people to see what is queued up, to get some additional testing and
> stabilisation and for people to sync up against.  And also to keep things
> like shared pagetables and dcache-rcu under test.

For what it's worth, the last mm kernel which booted on my old P-II IDE
test machine was 44-mm2. With 44-mm6 and this one I get an oops on boot.
Unfortunately it isn't written to disk, scrolls off the console, and
leaves the machine totally dead to anything less than a reset. I will try
2.5.46 base after I apply the few patches needed to make it compile, and
send you my config if you think it will help.

2.5.44 and all 4[45]-ac? builds booted and ran.

This is just a "problem present" notice, I have no decent info for
debugging.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
