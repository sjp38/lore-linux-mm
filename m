Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
Date: Sun, 28 Oct 2001 11:13:28 -0800 (PST)
Reply-To: barryn@pobox.com
In-Reply-To: <87k7xfk6zd.fsf@atlas.iskon.hr> from "Zlatko Calusic" at Oct 28, 2001 06:30:14 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20011028191328.CCC828A6EA@pobox.com>
From: barryn@pobox.com (Barry K. Nathan)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: zlatko.calusic@iskon.hr
Cc: Linus Torvalds <torvalds@transmeta.com>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Unfortunately, things didn't change on my first disk (IBM 7200rpm
> @home). I'm still getting low numbers, check the vmstat output at the
> end of the email.
> 
> But, now I found something interesting, other two disk which are on
> the standard IDE controller work correctly (writing is at 17-22
> MB/sec). The disk which doesn't work well is on the HPT366 interface,
> so that may be our culprit. Now I got the idea to check patches
> retrogradely to see where it started behaving poorely.
> 
> Also, one more thing, I'm pretty sure that under strange circumstances
> (specific alignment of stars) it behaves well (with appropriate
> writing speed). I just haven't yet pinpointed what needs to be done to
> get to that point.

I didn't read the entire thread, so this is a bit of a stab in the dark,
but:

This really reminds me of a problem I once had with a hard drive of
mine. It would usually go at 15-20MB/sec, but sometimes (under both
Linux and Windows) would slow down to maybe 350KB/sec. The slowdown, or
lack thereof, did seem to depend on the alignment of the stars. I lived
with it for a number of months, then started getting intermittent I/O
errors as well, as if the drive had bad sectors on disk.

The problem turned out to be insufficient ventilation for the controller
board on the bottom of the drive -- it was in the lowest 3.5" drive bay
in my case, so the bottom of the drive was snuggled next to a piece of
metal with ventilation holes. The holes were rather large (maybe 0.5"
diameter) -- and so were the areas without holes. Guess where one of the
drive's controller chips happened to be positioned, relative to the
holes? :( Moving the drive up a bit in the case, so as to allow 0.5"-1"
of space for air beneath the drive, fixed the problem (both the slowdown
and the I/O errors).

I don't know if this is your problem, but I'm mentioning it just in
case it is...

-Barry K. Nathan <barryn@pobox.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
