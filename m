Received: from mail.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA09072
	for <linux-mm@kvack.org>; Tue, 9 Feb 1999 04:43:20 -0500
Subject: Re: [PATCH] Re: swapcache bug?
References: <Pine.LNX.3.95.990208104249.606M-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 09 Feb 1999 01:15:28 -0600
In-Reply-To: Linus Torvalds's message of "Mon, 8 Feb 1999 10:48:06 -0800 (PST)"
Message-ID: <m1k8xs120f.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, masp0008@stud.uni-sb.de, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> Yes. The page offset will become a "sector offset" (I'd actually like to
LT> make it a page number, but then I'd have to break ZMAGIC dynamic loading
LT> due to the fractional page offsets, so it's not worth it for three extra
LT> bits), and that gives you 41 bits of addressing even on a 32-bit machine.
LT> Which is plenty - considering that by the time you need more than that
LT> you'd _really_ better be running on a larger machine anyway. 

???  With the latter OMAGIC format everthing is page aligned already.

I have a patch that removes page sharing support from ZMAGIC but keeps
everything functional.  Tested with a OMAGIC libc ZMAGIC doom and
ZMAGIC Xlibs.   This is on my queue for submission to 2.3.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
