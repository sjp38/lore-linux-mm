Date: Tue, 16 May 2000 15:43:26 +0200
From: Carlo Wood <carlo@alinoe.com>
Subject: "kswapd bug"
Message-ID: <20000516154326.A1077@a2000.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a report from yet another user who ran into
this "kswapd bug".

I bought a new harddisk (my first udma) and upgraded
at the same time to kernel 2.2.15 (from 2.2.12).

Then I had problems playing mp3's: the whole system
would 'freeze' for a fraction of a second to sometimes
even several seconds - making listening to music
impossible.  It clearly had to do with disk access,
and 2.2.x was supposed to be stable :/, so I bought
a new controller (Promise Ultra-66).

I couldn't get the Ultra to work with 2.2.x, so I
upgraded the kernel to 2.3.99-pre6 to find the SAME
system freezes :/.

Now I found out that the system was freezing every
time 'kswapd' was running. I then subbed to this list
and read in the past days that it is a known problem.

Today I upgraded to 2.3.99-pre9-pre1 and applied
classzone-28 (VM28).

Now I don't see system freezes anymore and can play
mp3's again without any problems. Everything seems
to run smooth again.

-- 
Carlo Wood <carlo@alinoe.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
