Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id B72A96B005C
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:21:51 -0500 (EST)
Received: by eekc41 with SMTP id c41so8248585eek.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 22:21:50 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
 <1324445481.20505.7.camel@joe2Laptop>
 <20111221054531.GB28505@barrios-laptop.redhat.com>
 <1324447099.21340.6.camel@joe2Laptop>
Date: Wed, 21 Dec 2011 07:21:42 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6ttagny3l0zgt@mpn-glaptop>
In-Reply-To: <1324447099.21340.6.camel@joe2Laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 21 Dec 2011 06:58:19 +0100, Joe Perches <joe@perches.com> wrote:=


> On Wed, 2011-12-21 at 14:45 +0900, Minchan Kim wrote:
>> I feel it's no problem as it is because it's very short function now
>> but it's not style we prefer.

> Who is this "we" you refer to?
>
> There's nothing suggesting your patch as a preferred style
> in Documentation/CodingStyle.

There is plenty that is not documented, ;) yet it seems the community pr=
efers
having ifdefs outside of the function.

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
