Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E4FBD900015
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 07:29:47 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hi2so1324737wib.1
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 04:29:47 -0800 (PST)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id s7si9653360wix.49.2014.11.06.04.29.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 04:29:46 -0800 (PST)
Received: by mail-wi0-f174.google.com with SMTP id d1so1322627wiv.1
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 04:29:46 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: CMA alignment question
In-Reply-To: <CAL1ERfMk+rhd=-MaLC2VVj61-T17_SVgKL4=Z_okhEYktFJ+tQ@mail.gmail.com>
References: <CADtm3G7DtGkvPk36Fiunwen8grw-94V6=iv82iusGumfNJkn-g@mail.gmail.com> <xa1tlhnq7ga7.fsf@mina86.com> <CADtm3G7bU6Y2aKco5Vb81KSqsy=FH9zmdDJm=Tixjoep1YeJ7Q@mail.gmail.com> <CAL1ERfMYmQcQ_sX7E0HC2bXmC-imh4T-7Q4nBVQRXkQSaTjvQQ@mail.gmail.com> <xa1tsihxwblf.fsf@mina86.com> <CAL1ERfMk+rhd=-MaLC2VVj61-T17_SVgKL4=Z_okhEYktFJ+tQ@mail.gmail.com>
Date: Thu, 06 Nov 2014 13:29:42 +0100
Message-ID: <xa1td290ikax.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Gregory Fong <gregory.0xf0@gmail.com>, linux-mm@kvack.org, Laura Abbott <lauraa@codeaurora.org>, iamjoonsoo.kim@lge.com, Marek Szyprowski <m.szyprowski@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>, Brian Norris <computersforpeace@gmail.com>

On Thu, Nov 06 2014, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> I agree the current code doesn't handle this issue properly.
> However, I prefer to add specific usage to CMA interface rather than
> modify the cma code, Because the latter hide the issue and could waste
> memory.

cma_alloc should handle whatever alignment caller uses.  Sure, if CMA
area has smaller alignment this may lead to wasted memory, but so can
allocation with small alignment followed by allocation with big
alignment.

If you're saying that platform should try to get the CMA area aligned
such that no alignment offset happens I agree.  If you're saying that
cma_alloc should fail (to properly align) an allocation request,
I disagree.

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
