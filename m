Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id A318E900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 12:57:51 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id gm9so979898lab.41
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 09:57:50 -0700 (PDT)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id ri5si3359614lbb.115.2014.10.28.09.57.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 09:57:49 -0700 (PDT)
Received: by mail-la0-f49.google.com with SMTP id ge10so984032lab.8
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 09:57:49 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: CMA: test_pages_isolated failures in alloc_contig_range
In-Reply-To: <544F9EAA.5010404@hurleysoftware.com>
References: <2457604.k03RC2Mv4q@avalon> <xa1tsii8l683.fsf@mina86.com> <544F9EAA.5010404@hurleysoftware.com>
Date: Tue, 28 Oct 2014 17:57:45 +0100
Message-ID: <xa1tfve8ku7q.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-sh@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

> On 10/28/2014 08:38 AM, Michal Nazarewicz wrote:
>> Like Laura wrote, the message is not (should not be) a problem in
>> itself:
>
> [...]
>
>> So as you can see cma_alloc will try another part of the cma region if
>> test_pages_isolated fails.
>>=20
>> Obviously, if CMA region is fragmented or there's enough space for only
>> one allocation of required size isolation failures will cause allocation
>> failures, so it's best to avoid them, but they are not always avoidable.
>>=20
>> To debug you would probably want to add more debug information about the
>> page (i.e. data from struct page) that failed isolation after the
>> pr_warn in alloc_contig_range.

On Tue, Oct 28 2014, Peter Hurley <peter@hurleysoftware.com> wrote:
> If the message does not indicate an actual problem, then its printk level=
 is
> too high. These messages have been reported when using 3.16+ distro kerne=
ls.

I think it could be argued both ways.  The condition is not an error,
since in many cases cma_alloc will be able to continue, but it *is* an
undesired state.  As such it's not an error but feels to me a bit more
then just information, hence a warning.  I don't care either way, though.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
