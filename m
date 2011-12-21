Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 353016B005A
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:24:14 -0500 (EST)
Received: by eekc41 with SMTP id c41so8250033eek.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 22:24:12 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
 <op.v6tsxbmb3l0zgt@mpn-glaptop>
 <20111221062232.GE28505@barrios-laptop.redhat.com>
Date: Wed, 21 Dec 2011 07:24:05 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6ttefog3l0zgt@mpn-glaptop>
In-Reply-To: <20111221062232.GE28505@barrios-laptop.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 21 Dec 2011 07:22:32 +0100, Minchan Kim <minchan@kernel.org> wro=
te:

> On Wed, Dec 21, 2011 at 07:13:49AM +0100, Michal Nazarewicz wrote:
>> On Wed, 21 Dec 2011 06:17:59 +0100, Minchan Kim <minchan@kernel.org> =
wrote:
>> >We don't like function body which include #ifdef.
>> >If we can, define null function to go out compile time.
>> >It's trivial, no functional change.
>>
>> It actually adds =E2=80=9Cflush_tlb_kenel_range()=E2=80=9D call to th=
e function so there
>> is functional change.
>
> Sorry. I can't understand your point.
> Why does it add flush_tlb_kernel_range in case of !CONFIG_DEBUG_PAGEAL=
LOC?

Uh, sorry, I've totally misread the function.  Never mind my comment.

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
