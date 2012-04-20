Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id E1C8C6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 13:43:39 -0400 (EDT)
Received: by eeke53 with SMTP id e53so3154129eek.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:43:38 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: Latest CMA patches required for kernel3.3 ?
References: <1334939015.7870.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Date: Fri, 20 Apr 2012 19:43:36 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.wc2riya33l0zgt@mpn-glaptop>
In-Reply-To: <1334939015.7870.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, PINTU KUMAR <pintu_agarwal@yahoo.com>

On Fri, 20 Apr 2012 18:23:35 +0200, PINTU KUMAR <pintu_agarwal@yahoo.com=
> wrote:
> Can somebody point me to the latest CMA patches repository?

git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.4-rc1-cm=
a-v24

> I need CMA patches for ubuntu.
>
> I upgraded my ubuntu kernel with kernel3.3 in order to use CMA.  But I=
 think
> CMA is not included with kernel 3.3 release.

No, it is not.  It also won't be in 3.4.  It may end up in 3.5.

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
