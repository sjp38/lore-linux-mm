From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14517.14173.39047.651808@dukat.scot.redhat.com>
Date: Thu, 24 Feb 2000 13:51:25 +0000 (GMT)
Subject: Re: mmap/munmap semantics
In-Reply-To: <Pine.LNX.4.10.10002241320590.27227-100000@linux14.zdv.uni-tuebingen.de>
References: <14517.8311.194809.598957@dukat.scot.redhat.com>
	<Pine.LNX.4.10.10002241320590.27227-100000@linux14.zdv.uni-tuebingen.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 24 Feb 2000 13:24:07 +0100 (MET), Richard Guenther
<richard.guenther@student.uni-tuebingen.de> said:

> Ah, this is cool - exactly what we need. I.e. an
> madvise(MADV_DONTNEED) and a subsequent munmap should not generate any
> disk io?

If you do the MADV_DONTNEED before the VM system has decided to flush
things out for its own reasons, then yes.  At least, according to one
reading of the specs.  There doesn't seem to be consensus yet on
precisely what this call is supposed to do --- BSD and Digital Unix man
pages are contradictory on this.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
