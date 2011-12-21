Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2EF406B005A
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:47:30 -0500 (EST)
Received: by eekc41 with SMTP id c41so8262640eek.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 22:47:28 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
 <1324445481.20505.7.camel@joe2Laptop>
 <20111221054531.GB28505@barrios-laptop.redhat.com>
 <1324447099.21340.6.camel@joe2Laptop> <op.v6ttagny3l0zgt@mpn-glaptop>
 <1324449156.21735.7.camel@joe2Laptop>
Date: Wed, 21 Dec 2011 07:47:17 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6tug3vi3l0zgt@mpn-glaptop>
In-Reply-To: <1324449156.21735.7.camel@joe2Laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 21 Dec 2011 07:32:36 +0100, Joe Perches <joe@perches.com> wrote:=


> On Wed, 2011-12-21 at 07:21 +0100, Michal Nazarewicz wrote:
>> it seems the community prefers
>> having ifdefs outside of the function.
>
> Some do, some don't.
>
> http://comments.gmane.org/gmane.linux.network/214543

This patch that you pointed to is against =E2=80=9C#ifdefs are ugly=E2=80=
=9D style
described in Documentation/SubmittingPatches.

> If it's not in coding style, I suggest
> it should be changed if it doesn't
> add some other useful value.

That my be true.  I guess no one took time to adding it to the document.=


-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
