Date: Thu, 7 Nov 2002 14:22:30 -0500 (EST)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.46-mm1
In-Reply-To: <3DCA9F50.1A9E5EC5@digeo.com>
Message-ID: <Pine.LNX.3.96.1021107141943.31227B-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Nov 2002, Andrew Morton wrote:

> "Martin J. Bligh" wrote:
> > 
> > > For what it's worth, the last mm kernel which booted on my old P-II IDE
> > > test machine was 44-mm2. With 44-mm6 and this one I get an oops on boot.
> > > Unfortunately it isn't written to disk, scrolls off the console, and
> > > leaves the machine totally dead to anything less than a reset. I will try
> > 
> > Any chance of setting up a serial console? They're very handy for
> > things like this ...
> > 
> 
> "vga=extended" gets you 50 rows, which is usually enough.

Doesn't seem to do anything, nor does vga=773 which I remember from the
days of using VESA modes. Serial is definitely the one of choice, this
video card is not cooperating. I'll bring a cable from the office Monday.

Stock 2.5.46 does the same thing, but so did 44 and 44-ac? is running
happily. I'll look. 

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
