Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA32716
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 12:56:27 -0500
Date: Mon, 25 Jan 1999 17:56:04 GMT
Message-Id: <199901251756.RAA06134@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990125141409.A29248@boole.suse.de>
References: <Pine.LNX.4.03.9901131557590.295-100000@mirkwood.dummy.home>
	<Pine.LNX.3.96.990113190617.185C-100000@laser.bogus>
	<199901132214.WAA07436@dax.scot.redhat.com>
	<19990114155321.C573@Galois.suse.de>
	<m1u2xjgtke.fsf@flinx.ccr.net>
	<19990125141409.A29248@boole.suse.de>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 25 Jan 1999 14:14:09 +0100, "Dr. Werner Fink" <werner@suse.de>
said:

> which leads into load upper 30.  You can see a great performance upto
> load to 25 ... 30+ *and* a brutal break down of that performance
> at this point.  The system is a PentiumII 400MHz with 32, 64, 128MB
> (mem=xxx) and SCSI only.  In comparision to 2.0.36 the performance
> is *beside of this break down* much better ...  that means that only
> the performance break down at high load is the real problem.

But is the performance of 2.0.36 better or worse at high load?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
