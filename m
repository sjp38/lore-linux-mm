Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B5A376B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 10:32:42 -0500 (EST)
Received: by gyg10 with SMTP id 10so879729gyg.14
        for <linux-mm@kvack.org>; Wed, 24 Nov 2010 07:32:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTimo1BR=mSJ6wPQwrL4FDNv=_TfanPPTT7uWx7hQ@mail.gmail.com>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com>
	<20101122161158.02699d10.akpm@linux-foundation.org>
	<1290501502.2390.7029.camel@nimitz>
	<AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com>
	<1290529171.2390.7994.camel@nimitz>
	<AANLkTikCn-YvORocXSJ1Z+ovYNMhKF7TaX=BHWKwrQup@mail.gmail.com>
	<AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com>
	<AANLkTimo1BR=mSJ6wPQwrL4FDNv=_TfanPPTT7uWx7hQ@mail.gmail.com>
Date: Wed, 24 Nov 2010 16:32:39 +0100
Message-ID: <AANLkTi=yV02oY5AmNAYr+ZF0RUgVv8gkeP+D9_CcOfLi@mail.gmail.com>
Subject: Re: Sudden and massive page cache eviction
From: =?UTF-8?Q?Peter_Sch=C3=BCller?= <scode@spotify.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> I forgot to address the second part of this question: How would I best
>> inspect whether the kernel is doing that?
>
> You can, for example, record
>
> =C2=A0cat /proc/meminfo | grep Huge
>
> for large page allocations.

Those show zero a per my other post. However I got the impression Dave
was asking about regular but larger-than-one-page allocations internal
to the kernel, while the Huge* lines in /proc/meminfo refers to
allocations specifically done by userland applications doing huge page
allocation on a system with huge pages enabled - or am I confused?

> The "pagesperslab" column of /proc/slabinfo tells you how many pages
> slab allocates from the page allocator.

Seems to be what vmstat -m reports.

--=20
/ Peter Schuller aka scode

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
