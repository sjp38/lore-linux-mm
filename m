Date: Mon, 30 Aug 1999 13:51:14 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: accel handling
In-Reply-To: <14282.43218.149092.491404@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9908301313300.5070-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> For graphics, latency is important.  You can't afford to arbitrarily
> batch things up into things only getting sent every hundred msec or so.
> Also, depending on what you are doing, you can be streaming things to
> the accel engine _fast_: for 3D, for example, the DRI people talk about
> sending a new command queue to an accelerator at the rate of a few
> thousand per second.  For 2D animation you are probably talking about
> at least hundreds per second, depending on how much is going on.  Much
> less than that and the latency becomes visible.

Then the question is how are DRI handling this. I'm assuming they don't
allow access to the framebuffer. Then it looks like the best solution not
allow any accels when you have /dev/fb mmapped. Then their still the
problem of fbcon drivers that use accels to do drawing operations. What if
the user is writing to the framebuffer device while a accel is being
processed in the kernel. It locks the machine hard. I know from personal
experience with the matrox framebuffer device. One in ten times of
starting X it locks my machine and I have to reboot. This problem needs to
be solved and its no longer a PC problem when this kind of hardware can
now run on SPARCs and PPC. Now having fbcon remove all accel code would be
really bad on performace for high end modes like 1600x1280x32. These modes
are going to become common place ove rthe next few years.   

> > The secert is to do a as few times possible.
> 
> If that results in a performance drop, then it kind of defeats the idea
> of having an accel engine. 

Right, you have to empty the accel queue at each frame refresh. Faster
than that would be pointless. Slower than that would be really bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
