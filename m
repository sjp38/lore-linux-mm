Subject: Re: Process not given >890MB on a 4MB machine ?????????
References: <5D2F375D116BD111844C00609763076E050D164D@exch-staff1.ul.ie>
	<20010920125616.A14985@top.worldcontrol.com>
From: Thierry Vignaud <tvignaud@mandrakesoft.com>
Date: 20 Sep 2001 22:36:06 +0200
In-Reply-To: <20010920125616.A14985@top.worldcontrol.com> (brian@worldcontrol.com's message of "Thu, 20 Sep 2001 12:56:16 -0700")
Message-ID: <m23d5heh1l.fsf@vador.mandrakesoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: brian@worldcontrol.com
Cc: "Gabriel.Leen" <Gabriel.Leen@ul.ie>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

brian@worldcontrol.com writes:

> > The problem in a nutshell is:
> >
> > a) I have a 4GB ram 1.7Gh Xeon box
> > b) I'm running a process which requires around 3GB of ram
> > c) RedHat 2.4.9 will only give it 890MB, then core dumps with the warning
> > "segmentation fault"
> > when it reaches this memory usage and "asks for more"
>
> That is exacly what I've seen.
>
> The limit I ran into was in glibc.  My code used malloc, and apparently
> some versions of malloc in glibc try "harder" than others to allocate
> memory.  Check your version of glibc and try a later one if available.

the problem is that the glibc has various algo to allocate memory, depending of
the requested size (greater than a page or not), and use the "classic" sbrk() if
lesser (bellow 1Gb) or an anonymous mapping (from 1Gb to a limit that depends of
the virtual memory split between the kernel and the process space).
therefore small malloc will eat space below 1GB and cannot use more than this GB
(minus the process text & data).
anyway for small objects set, there's more efficient techniques (one big malloc
is less costly than several small malloc()).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
