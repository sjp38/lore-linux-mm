Received: from localhost (hahn@localhost)
	by coffee.psychology.mcmaster.ca (8.9.3/8.9.3) with ESMTP id UAA16722
	for <linux-mm@kvack.org>; Mon, 16 Oct 2000 20:23:55 -0400
Date: Mon, 16 Oct 2000 20:23:55 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: too many context switches.
In-Reply-To: <Pine.LNX.4.10.10010081444380.26729-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.LNX.4.10.10010162020200.15363-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm following up to my earlier message, where I pointed out
that current kernels generate a RIDICULOUS number of context
switches when streaming to disk.  I've tracked this down a little
and the problem is that bdflush is being awoken sometimes 
30-40000 times per second.  this is obviously not a good thing!

I haven't figured out why, but the bdflush loop is very odd
looking, since it contains a schedule() but no wait_on.  could 
someone explain how it's supposed to be throttled?

thanks, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
