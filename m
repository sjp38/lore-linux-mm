Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id RAA00420
	for <linux-mm@kvack.org>; Fri, 23 Jun 2000 17:08:15 +0100
Subject: Re: [RFC] RSS guarantees and limits
References: <Pine.LNX.4.21.0006221834530.1137-100000@duckman.distro.conectiva> <m2itv19vt9.fsf@boreas.southchinaseas> <20000623005945.E9244@redhat.com>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 23 Jun 2000 17:08:14 +0100
In-Reply-To: Stephen Tweedie's message of "Fri, 23 Jun 2000 00:59:45 +0100"
Message-ID: <m2u2ekcrdd.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen Tweedie <sct@redhat.com> writes:

[...]

> The RSS bounds are *DYNAMIC*.  If there is contention for memory ---
> if lots of other processes want the memory that that emacs is 
> holding --- then absolutely you want to cut back on the emacs RSS.
> If there is no competition, and emacs is the only active process, then
> there is no need to prune its RSS.

Yes, I agree with both parts. The second part is what I was trying to
get across with the example because I thought that case was being
ignored.

I thought the part of the proposal was to control its RSS and give the
surplus to the little processes so that when the admin tried to telnet
in to kill it, inetd would be in memory and nicely responsive.

You (Stephen) said earlier:
> It is critically important that when under memory pressure, a
> system administrator can still log in and kill any runaway
> processes.  [...]

I took that to imply that inetd would have to be kept in memory. Sorry
for the confusion caused.

[...]

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
