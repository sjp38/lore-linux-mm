Date: Mon, 13 Dec 2004 03:34:54 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: Correctly determine free memory amount before swapping
Message-ID: <20041213093454.GB29377@lnx-holt.americas.sgi.com>
References: <06EF4EE36118C94BB3331391E2CDAAD9D49E06@exil1.paradigmgeo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <06EF4EE36118C94BB3331391E2CDAAD9D49E06@exil1.paradigmgeo.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gregory Giguashvili <Gregoryg@ParadigmGeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If you are looking for a quick way to determine from userland how much
extra memory will be shaken free by a large number of anonymous page
faults, you are going to be hard pressed to find it.

One rough indicator is to time the page faults.  Simply grab time before
and after you first touch a page and if the delay is drastically larger
than when you started for say 5 pages in a row, you know you are into
swap area.  You will need to experiment, but that is a starting point.

Alternatively, you could have a second thread that is simply prefaulting
pages.  I have found that most times on a system with modest I/O, I
can have five threads doing strided accesses that fault about as fast
as the I/O subsystem can free memory.  Sometimes it takes 7.

Good Luck,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
