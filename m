Date: Thu, 24 Feb 2000 13:24:07 +0100 (MET)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: Re: mmap/munmap semantics
In-Reply-To: <14517.8311.194809.598957@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.10002241320590.27227-100000@linux14.zdv.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Feb 2000, Stephen C. Tweedie wrote:

> Hi,
> 
> On Thu, 24 Feb 2000 03:35:02 +0100, Jamie Lokier
> <lk@tantalophile.demon.co.uk> said:
> 
> > I don't think MADV_DONTNEED actually drops privately modified data does
> > it?  
> 
> Yes, it does.  From the DU man pages:
> 
>       MADV_DONTNEED
>                       Do not need these pages
> 
>                       The system will free any whole pages in the specified
>                       region.  All modifications will be lost and any swapped
>                       out pages will be discarded.  Subsequent access to the
>                       region will result in a zero-fill-on-demand fault as
>                       though it is being accessed for the first time.
>                       Reserved swap space is not affected by this call.

Ah, this is cool - exactly what we need. I.e. an madvise(MADV_DONTNEED)
and a subsequent munmap should not generate any disk io?

> Regarding the other half of the problem --- zeroing out a portion of a
> file without further IO --- the splice code I hope to have using kiobufs
> in 2.5 will allow this to be done very easily.  You'll be able to take a
> region of /dev/zero and splice it into your open file with zero-copy.

Cool, too. So for now we will stay with zeroing by reading from /dev/zero
which does vm tricks in linux already.

Richard.

> --Stephen
> 
> _______________________________________________
> glame-devel mailing list
> glame-devel@lists.sourceforge.net
> http://lists.sourceforge.net/mailman/listinfo/glame-devel
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
