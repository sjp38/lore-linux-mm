From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008172000.NAA87506@google.engr.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 17 Aug 2000 13:00:56 -0700 (PDT)
In-Reply-To: <200008171930.MAA23963@pizda.ninka.net> from "David S. Miller" at Aug 17, 2000 12:30:42 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.redhat.com, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

> 
>    From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
>    Date: Thu, 17 Aug 2000 12:32:35 -0700 (PDT)
> 
> BTW, I've sed s/vger.rutgers.edu/vger.redhat.com/
> 
>    Wait! You are saying you have a scheme that will prevent writers 
>    from writing buggy code that happens to work only on 32Mb i386 ...
>    Go ahead, I am all ears :-)
> 
> I understand your point, but please understand mine.
> 
> One might laugh, but after I read and really considered some of the
> points made by the author of "Writing Solid Code" in that book, I
> realized that one of my jobs as someone creating an API is that I
> should be trying as hard as possible to design it such that it is next
> to impossible to misuse it.

Unfortunately, where there's a will to misuse, there usually is a way :-(

And that's doubly hard to accept after all the hard work that gets into
creating the API ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
