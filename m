Date: Fri, 12 Oct 2001 07:54:29 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [CFT][PATCH] smoother VM for -ac
Message-ID: <20011012075429.N714@athlon.random>
References: <1002861682.866.3.camel@phantasy>; <20011012070930.J714@athlon.random> <3BC64882.27834.2D200B0@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3BC64882.27834.2D200B0@localhost>; from jlmales@softhome.net on Fri, Oct 12, 2001 at 01:33:54AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "John L. Males" <jlmales@softhome.net>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 12, 2001 at 01:33:54AM -0500, John L. Males wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> - -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Andrea,
> 
> I can do.  I see this is a VM is of keen interest.  Question for you.
>  To really compare apples to apples I could spider a web site or two
> just find.  Then the challenge is to replay the "test" on the gui,
> say KDE for example.  Do you know of any good tools that would alow
> me to do a GUI record/playback?  I can then do an A vs B comparison.

For testing the repsonsiveness I usually check the startup time of
applications like netscape with cold cache, later I just start an high
vm load on my desktop and I see how long can I keep working without
being too hurted. the first is certainly a measurable test, the second
isn't reliable since it doesn't generate raw numbers and it's too much
in function of the human feeling but it shows very well any patological
problem of the code. But they may not be the best tests.

> Also, remind me, can I find your kernel to test on the SuSE FTP site
> or via kernel.org.  I had tried a few of the SuSE 2.4 kernels a few
> levels back and I recall I was going to the people directory of the
> FTP site and getting them from mantel I seem to recollect.

That's still fine procedure, only make sure to pick the latest 2.4.12
one based on 2.4.12aa1 before running the tests. thanks,

> I will search about on internet to see if I can find a
> record/playback too to get some sort of good A vs B comparison.
> 
> 
> Regards,
> 
> John L. Males
> Willowdale, Ontario
> Canada
> 12 October 2001 01:33
> mailto:jlmales@softhome.net

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
