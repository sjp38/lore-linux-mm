From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14282.43218.149092.491404@dukat.scot.redhat.com>
Date: Mon, 30 Aug 1999 16:52:49 +0100 (BST)
Subject: Re: accel handling
In-Reply-To: <Pine.LNX.4.10.9908301043070.3506-100000@imperial.edgeglobal.com>
References: <14282.37533.98879.414300@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9908301043070.3506-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 30 Aug 1999 10:50:11 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> The way the accel engine will work is that it will batch accel commands.
> Then when full flush them to the accel engine. So we can batch a hugh
> number of commands to avoid the expensive process of flipping page tables.
> Of course the buffer is of variable size. The size determined by how many
> accel commands you want to send to the engine to display a frame. So a
> complex scene would be worth it.  

For graphics, latency is important.  You can't afford to arbitrarily
batch things up into things only getting sent every hundred msec or so.
Also, depending on what you are doing, you can be streaming things to
the accel engine _fast_: for 3D, for example, the DRI people talk about
sending a new command queue to an accelerator at the rate of a few
thousand per second.  For 2D animation you are probably talking about
at least hundreds per second, depending on how much is going on.  Much
less than that and the latency becomes visible.
 
> The secert is to do a as few times possible.

If that results in a performance drop, then it kind of defeats the idea
of having an accel engine.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
