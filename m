Message-ID: <34F2ABF9.1792@ife.ee.ethz.ch>
Date: Tue, 24 Feb 1998 12:16:09 +0100
From: Thomas Sailer <sailer@ife.ee.ethz.ch>
MIME-Version: 1.0
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
References: <Pine.LNX.3.95.980220001508.8311A-100000@as200.spellcast.com> <199802232317.XAA06136@dax.dcs.ed.ac.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Rik van Riel <H.H.vanRiel@fys.ruu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen

For the sound driver we need some way to postpone driver
shutdown until the last mmap to driver memory is unmapped
(or alternatively to force unmapping on driver close).
Could you or anyone else of the linux-mm community provide
the necessary hook in the linux mm layer? This is one
of the nasty problems with the current sound driver
that should IMHO be fixed before 2.2...

Thanks

Tom
