Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 162476B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:17:18 -0400 (EDT)
Received: by iwn39 with SMTP id 39so3768850iwn.14
        for <linux-mm@kvack.org>; Mon, 24 May 2010 07:17:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils> <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
	<AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Date: Mon, 24 May 2010 15:16:47 +0100
Message-ID: <AANLkTikjyi1XUzO2VySrXL1evPCRx8YepOAs0I9HCvtp@mail.gmail.com>
Subject: Re: TMPFS over NFSv4
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

hi Hugh.

On Mon, May 24, 2010 at 10:57 AM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, May 24, 2010 at 2:26 AM, Tharindu Rukshan Bamunuarachchi
>
> If patch conflicts are a problem, you really only need to put in the
> two-liner patch to mm/mmap.c: Alan was seeking perfection in
> the rest of the patch, but you can get away without it.
>

I will just add it by hand.

>
>
> So what you see fits with what Alan was fixing.
>

Yes, of courese.

BTW, that was typo and it should be overcommit_memory.
I have done testing in our test severs and "2 > overcommit_memory"
triggers the issue.

OTOH, I have reported the issue Novell.
Hope they will apply necessary patch in next release.


> Hugh
>


Thankx a lot/

__
tharindu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
