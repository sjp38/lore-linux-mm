Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3216B0069
	for <linux-mm@kvack.org>; Sat, 31 Dec 2016 00:08:51 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id x140so80554219lfa.2
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 21:08:51 -0800 (PST)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id 142si20636080lfe.154.2016.12.30.21.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Dec 2016 21:08:49 -0800 (PST)
Received: by mail-lf0-x22c.google.com with SMTP id t196so246301986lff.3
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 21:08:49 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
In-Reply-To: <87bmvtxizn.fsf@eliezer.anholt.net>
References: <20161229023131.506-1-eric@anholt.net> <20161229091256.GF29208@dhcp22.suse.cz> <87wpeitzld.fsf@eliezer.anholt.net> <xa1td1ga74v7.fsf@mina86.com> <8737h65nr5.fsf@eliezer.anholt.net> <xa1ta8bd7uy7.fsf@mina86.com> <87bmvtxizn.fsf@eliezer.anholt.net>
Date: Sat, 31 Dec 2016 06:08:45 +0100
Message-ID: <xa1t7f6g7kiq.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Anholt <eric@anholt.net>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-stable <stable@vger.kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, Vlastimil Babka <vbabka@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri, Dec 30 2016, Eric Anholt wrote:
> OK, so the design is bad.  When you said bug, I definitely thought you
> were saying that the message shouldn't happen in the design.
>
> Given CMA's current design, should everyone using CMA see their logs
> slowly growing with this message that is an secret code for "CMA's
> design hasn't yet changed"?

Just to be clear, it=E2=80=99s not CMA=E2=80=99s design; it=E2=80=99s movab=
le page=E2=80=99s design that
is bad (at least in the context of this discussion).

But yes, because of the way movable pages are, everyone is likely to see
the message.

> If you want to have people be able to track how often this is
> happening, let's make a perf event for it or something instead.

Sure.

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
