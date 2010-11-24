Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CD6576B0087
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:20:32 -0500 (EST)
Received: by gxk25 with SMTP id 25so26226gxk.14
        for <linux-mm@kvack.org>; Wed, 24 Nov 2010 06:20:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com>
	<20101122161158.02699d10.akpm@linux-foundation.org>
	<1290501502.2390.7029.camel@nimitz>
	<AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com>
	<1290529171.2390.7994.camel@nimitz>
	<AANLkTikCn-YvORocXSJ1Z+ovYNMhKF7TaX=BHWKwrQup@mail.gmail.com>
	<AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com>
Date: Wed, 24 Nov 2010 16:20:30 +0200
Message-ID: <AANLkTimo1BR=mSJ6wPQwrL4FDNv=_TfanPPTT7uWx7hQ@mail.gmail.com>
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
>>> Do you have any large page (hugetlbfs) or other multi-order (> 1 page)
>>> allocations happening in the kernel?
>
> I forgot to address the second part of this question: How would I best
> inspect whether the kernel is doing that?

You can, for example, record

  cat /proc/meminfo | grep Huge

for large page allocations.

> Looking at the kmalloc() sizes from vmstat -m I have the following on
> one of the machines (so very few larger than 4096). But I suspect you
> are asking for something different?

The "pagesperslab" column of /proc/slabinfo tells you how many pages
slab allocates from the page allocator.

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
