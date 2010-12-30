Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 25A2A6B00B1
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 16:25:27 -0500 (EST)
Received: by iwn40 with SMTP id 40so11811589iwn.14
        for <linux-mm@kvack.org>; Thu, 30 Dec 2010 13:25:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1012291231540.22566@sister.anvils>
References: <AANLkTinbqG7sXxf82wc516snLoae1DtCWjo+VtsPx2P3@mail.gmail.com>
	<20101122154754.e022d935.akpm@linux-foundation.org>
	<AANLkTi=AiJ1MekBXZbVj3f2pBtFe52BtCxtbRq=u-YOR@mail.gmail.com>
	<20101129152500.000c380b.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1011300939520.6633@tigran.mtv.corp.google.com>
	<alpine.LSU.2.00.1012291231540.22566@sister.anvils>
Date: Thu, 30 Dec 2010 22:25:25 +0100
Message-ID: <AANLkTi=ZuOJ07yN-nqso_pX_NS90eKrPD=vG9-_a59vG@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> I guess the latter is the more likely: maybe the truncate_count/restart
>> logic isn't working properly. =C2=A0I'll try to check over that again la=
ter -
>> but will be happy if someone else beats me to it.
>
> I have since found an omission in the restart_addr logic: looking back
> at the October 2004 history of vm_truncate_count, I see that originally
> I designed it to work one way, but hurriedly added a 7/6 redesign when
> vma splitting turned out to leave an ambiguity. =C2=A0I should have updat=
ed
> the protection in mremap move at that time, but missed it.
>
> Robert, please try out the patch below (should apply fine to 2.6.35):

In the beginning  of Jan (3-4) at earliest I'm afraid, i.e. when I
manage to get to my console-over-rs232 setup.

> I'm hoping this will fix what the fuzzer found, but it's still quite
> possible that it found something else wrong that I've not yet noticed.
> The patch could probably be cleverer (if we exported the notion of
> restart_addr out of mm/memory.c), but I'm more in the mood for being
> safe than clever at the moment.

--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
