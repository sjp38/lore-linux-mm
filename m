Message-ID: <3905DFCF.B8695E16@mandrakesoft.com>
Date: Tue, 25 Apr 2000 14:11:27 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: 2.3.x mem balancing
References: <Pine.LNX.4.21.0004251437540.10408-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Another thing which we probably want before 2.4 is scanning
> big processes more agressively than small processes. I've
> implemented most of what is needed for that and it seems to
> have a good influence on performance because:
> - small processes suffer less from the presence of memory hogs
> - memory hogs have their pages aged more agressively, making it
>   easier for them to do higher throughput from/to swap or disk

Since you do not mention a new sysctl here...

The change you propose is policy.  Favoring interactivity over memory
hogs is not always a good idea and should be left up to the sysadmin not
kernel hacker to decide.

	Jeff




-- 
Jeff Garzik              | Nothing cures insomnia like the
Building 1024            | realization that it's time to get up.
MandrakeSoft, Inc.       |        -- random fortune
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
