Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24F996B0038
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 17:22:31 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id t196so142039282lff.3
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 14:22:31 -0800 (PST)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id d5si31718226lfc.359.2016.12.29.14.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Dec 2016 14:22:29 -0800 (PST)
Received: by mail-lf0-x22d.google.com with SMTP id c13so228431024lfg.0
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 14:22:29 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
In-Reply-To: <87wpeitzld.fsf@eliezer.anholt.net>
References: <20161229023131.506-1-eric@anholt.net> <20161229091256.GF29208@dhcp22.suse.cz> <87wpeitzld.fsf@eliezer.anholt.net>
Date: Thu, 29 Dec 2016 23:22:20 +0100
Message-ID: <xa1td1ga74v7.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Anholt <eric@anholt.net>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-stable <stable@vger.kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, Vlastimil Babka <vbabka@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Dec 29 2016, Eric Anholt wrote:
> Michal Hocko <mhocko@kernel.org> writes:
>
>> This has been already brought up
>> http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz and there
>> was a proposed patch for that which ratelimited the output
>> http://lkml.kernel.org/r/20161130132848.GG18432@dhcp22.suse.cz resp.
>> http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-terrar=
um.net
>>
>> then the email thread just died out because the issue turned out to be a
>> configuration issue. Michal indicated that the message might be useful
>> so dropping it completely seems like a bad idea. I do agree that
>> something has to be done about that though. Can we reconsider the
>> ratelimit thing?
>
> I agree that the rate of the message has gone up during 4.9 -- it used
> to be a few per second.

Sounds like a regression which should be fixed.

This is why I don=E2=80=99t think removing the message is a good idea.  If =
you
suddenly see a lot of those messages, something changed for the worse.
If you remove this message, you will never know.

> However, if this is an expected path during normal operation,

This depends on your definition of =E2=80=98expected=E2=80=99 and =E2=80=98=
normal=E2=80=99.

In general, I would argue that the fact those ever happen is a bug
somewhere in the kernel =E2=80=93 if memory is allocated as movable, it sho=
uld
be movable damn it!

> we shouldn't be clogging dmesg with it at all.  So, I'd rather we go
> with this patch, that is unless the KERN_DEBUG in your ratelimit patch
> would keep it out of journald as well (un-ratelimited, journald was
> eating 10% of a CPU processing the message, and I'd rather it not be
> getting logged at all).

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
