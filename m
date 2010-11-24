Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BBDC26B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 12:46:30 -0500 (EST)
Received: by yxl31 with SMTP id 31so3149047yxl.14
        for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:46:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=yV02oY5AmNAYr+ZF0RUgVv8gkeP+D9_CcOfLi@mail.gmail.com>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com>
	<20101122161158.02699d10.akpm@linux-foundation.org>
	<1290501502.2390.7029.camel@nimitz>
	<AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com>
	<1290529171.2390.7994.camel@nimitz>
	<AANLkTikCn-YvORocXSJ1Z+ovYNMhKF7TaX=BHWKwrQup@mail.gmail.com>
	<AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com>
	<AANLkTimo1BR=mSJ6wPQwrL4FDNv=_TfanPPTT7uWx7hQ@mail.gmail.com>
	<AANLkTi=yV02oY5AmNAYr+ZF0RUgVv8gkeP+D9_CcOfLi@mail.gmail.com>
Date: Wed, 24 Nov 2010 19:46:28 +0200
Message-ID: <AANLkTi=PXoMA0gv53_7h16u1259sh1uOxg2cSXYSXThv@mail.gmail.com>
Subject: Re: Sudden and massive page cache eviction
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-1?Q?Peter_Sch=FCller?= <scode@spotify.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peter,

2010/11/24 Peter Sch=FCller <scode@spotify.com>:
>>> I forgot to address the second part of this question: How would I best
>>> inspect whether the kernel is doing that?
>>
>> You can, for example, record
>>
>> =A0cat /proc/meminfo | grep Huge
>>
>> for large page allocations.
>
> Those show zero a per my other post. However I got the impression Dave
> was asking about regular but larger-than-one-page allocations internal
> to the kernel, while the Huge* lines in /proc/meminfo refers to
> allocations specifically done by userland applications doing huge page
> allocation on a system with huge pages enabled - or am I confused?

He was asking about both (large page allocations and higher order allocatio=
ns).

>> The "pagesperslab" column of /proc/slabinfo tells you how many pages
>> slab allocates from the page allocator.
>
> Seems to be what vmstat -m reports.

No, "vmstat -m" reports _total number_ of pages allocated. We're
interested in how many pages slab allocator whenever it needs to
allocate memory for a new slab. That's represented by the
"pagesperslab" column of /proc/slabinfo from which you can deduce the
page allocation order.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
