Message-ID: <3B6369DE.F9085405@zip.com.au>
Date: Sun, 29 Jul 2001 11:41:50 +1000
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
References: <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva>,
		<Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva> <01072822131300.00315@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> Oh, by the way, my suspicions about the flakiness of dbench as a
> benchmark were confirmed: under X, having been running various memory
> hungry applications for a while, dbench on vanilla 2.4.7 turned in a 7%
> better performance (with a distinctly different process termination
> pattern) than in text mode after a clean reboot.

Be very wary of optimising for dbench.

It's a good stress tester, but I don't think it's a good indicator of how
well an fs or the VM is performing.  It does much more writing than a
normal workload mix.  It generates oceans of metadata.

It would be very useful to have a standardised and very carefully
chosen set of tests which we could use for evaluating fs and kernel
performance.  I'm not aware of anything suitable, really.  It would
have to be a whole bunch of datapoints sprinkled throughout a
multidimesional space.  That's what we do at present, but it's ad-hoc.
 
> Maybe somebody can explain to me why there is sometimes a long wait
> between the "+" a process prints when it exits and the "*" printed in
> the parent's loop on waitpid(0, &status, 0).  And similarly, why all
> the "*"'s are always printed together.

Heaven knows.  Seems that sometimes one client makes much more
progress than others.  When that happens, other clients coast
along on its coattails and they start exitting waaay earlier
than they normally do.  The overall runtime can vary by a factor
of two between identical invokations.

The fact that a kernel change causes a decrease in dbench throughput
is by no means a reliable indication that is was a bad change.  More
information needed.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
