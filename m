Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E25806B0082
	for <linux-mm@kvack.org>; Wed, 16 May 2012 09:56:51 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so1530510obb.14
        for <linux-mm@kvack.org>; Wed, 16 May 2012 06:56:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.02.1205160935340.1763@tux.localdomain>
References: <1337108498-4104-1-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1205151527150.11923@router.home>
	<alpine.LFD.2.02.1205160935340.1763@tux.localdomain>
Date: Wed, 16 May 2012 22:56:50 +0900
Message-ID: <CAAmzW4PWQiKbs+mdnwG18R=iWHLT=4Bwn8iA110PJaKuvG_AQQ@mail.gmail.com>
Subject: Re: [PATCH] slub: fix a memory leak in get_partial_node()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

2012/5/16 Pekka Enberg <penberg@kernel.org>:
> <On Tue, 15 May 2012, Christoph Lameter wrote:
>
>> On Wed, 16 May 2012, Joonsoo Kim wrote:
>>
>> > In the case which is below,
>> >
>> > 1. acquire slab for cpu partial list
>> > 2. free object to it by remote cpu
>> > 3. page->freelist =3D t
>> >
>> > then memory leak is occurred.
>>
>> Hmmm... Ok so we cannot assign page->freelist in get_partial_node() for
>> the cpu partial slabs. It must be done in the cmpxchg transition.
>>
>> Acked-by: Christoph Lameter <cl@linux.com>
>
> Joonsoo, can you please fix up the stable submission format, add
> Christoph's ACK and resend?
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Pekka

Thanks for comment.
I'm a kernel newbie,
so could you please tell me how to fix up the stable submission format?
I'm eager to fix it up, but I don't know how to.

I read stable_kernel_rules.txt, this article tells me I must note
upstream commit ID.
Above patch is not included in upstream currently, so I can't find
upstream commit ID.
Is 'Acked-by from MAINTAINER' sufficient for submitting to stable-kernel?
Is below format right for stable submission format?


To: Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman
<gregkh@linuxfoundation.org>, Pekka Enberg <penberg@kernel.org>

CC: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
linux-mm@kvack.org

[ Upstream commit xxxxxxxxxxxxxxxxxxx ]

Comment is here

Acked-by:
Signed-off-by:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
