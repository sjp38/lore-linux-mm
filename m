Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005101708590.1489-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Wed, 10 May 2000 17:16:05 -0700 (PDT)"
Date: 11 May 2000 03:04:37 +0200
Message-ID: <yttog6doq1m.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "James H. Cloos Jr." <cloos@jhcloos.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

linus> Which makes the whole process much more streamlined, and makes the numbers
linus> more repeatable. It also fixes the problem with dirty buffer cache data
linus> much more efficiently than the kflushd approach, and mmap002 is not a
linus> problem any more. At least for me.

linus> [ I noticed that mmap002 finishes a whole lot faster if I never actually
linus> wait for the writes to complete, but that had some nasty behaviour under
linus> low memory circumstances, so it's not what pre7-9 actually does. I
linus> _suspect_ that I should start actually waiting for pages only when
linus> priority reaches 0 - comments welcomed, see fs/buffer.c and the
linus> sync_page_buffers() function ]

Hi
        I have done my normal mmap002 test and this goes slower than
ever, it takes something like 3m50 seconds to complete, (pre7-8 2m50,
andrea classzone 2m8, and 2.2.15 1m55 for reference).  I have no more
time now to do more testing, I will continue tomorrow late.  My
findings are:

real    3m41.403s
user    0m16.010s
sys     0m36.890s


It takes the same user time than anterior versions, but the system
time has aumented a lot, it was ~10/12 seconds in pre7-8 and around 8
in classzone and 2.2.15.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
