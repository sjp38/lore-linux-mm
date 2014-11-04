Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC4DF6B00AF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 08:35:24 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id q1so869896lam.38
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 05:35:23 -0800 (PST)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id 4si712368laq.88.2014.11.04.05.35.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 05:35:23 -0800 (PST)
Received: by mail-lb0-f170.google.com with SMTP id z12so2738991lbi.1
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 05:35:23 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: alloc_contig_range: demote pages busy message from warn to info
In-Reply-To: <5458C501.3040505@hurleysoftware.com>
References: <2457604.k03RC2Mv4q@avalon> <1415033873-28569-1-git-send-email-mina86@mina86.com> <20141104054307.GA23102@bbox> <5458C501.3040505@hurleysoftware.com>
Date: Tue, 04 Nov 2014 14:35:19 +0100
Message-ID: <xa1tvbmv6qco.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 04 2014, Peter Hurley <peter@hurleysoftware.com> wrote:
> On 11/04/2014 12:43 AM, Minchan Kim wrote:
>> Hello,
>>=20
>> On Mon, Nov 03, 2014 at 05:57:53PM +0100, Michal Nazarewicz wrote:
>>> Having test_pages_isolated failure message as a warning confuses
>>> users into thinking that it is more serious than it really is.  In
>>> reality, if called via CMA, allocation will be retried so a single
>>> test_pages_isolated failure does not prevent allocation from
>>> succeeding.
>>>
>>> Demote the warning message to an info message and reformat it such
>>> that the text =E2=80=9Cfailed=E2=80=9D does not appear and instead a le=
ss worrying
>>> =E2=80=9CPFNS busy=E2=80=9D is used.
>>=20
>> What do you expect from this message? Please describe it so that we can
>> review below message helps your goal.
>
> I expect this message to not show up in logs unless there is a real probl=
em.

So frankly I don't care.  Feel free to send a patch removing the message
all together.  I'll be happy to ack it.

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
