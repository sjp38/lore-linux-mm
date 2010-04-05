Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5E0206B0214
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 20:59:20 -0400 (EDT)
Received: by pzk30 with SMTP id 30so2612665pzk.12
        for <linux-mm@kvack.org>; Sun, 04 Apr 2010 17:59:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100404195533.GA8836@logfs.org>
References: <alpine.LFD.2.00.1004041125350.5617@localhost>
	 <1270396784.1814.92.camel@barrios-desktop>
	 <20100404160328.GA30540@ioremap.net>
	 <1270398112.1814.114.camel@barrios-desktop>
	 <20100404195533.GA8836@logfs.org>
Date: Mon, 5 Apr 2010 09:59:18 +0900
Message-ID: <p2g28c262361004041759n52f5063dhb182663321d918bb@mail.gmail.com>
Subject: Re: why are some low-level MM routines being exported?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@logfs.org>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 5, 2010 at 4:55 AM, J=C3=B6rn Engel <joern@logfs.org> wrote:
> On Mon, 5 April 2010 01:21:52 +0900, Minchan Kim wrote:
>> >
>> Until now, other file system don't need it.
>> Why do you need?
>
> To avoid deadlocks. =C2=A0You tell logfs to write out some locked page, l=
ogfs
> determines that it needs to run garbage collection first. =C2=A0Garbage
> collection can read any page. =C2=A0If it called find_or_create_page() fo=
r
> the locked page, you have a deadlock.

Could you do it with add_to_page_cache and pagevec_lru_add_file?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
