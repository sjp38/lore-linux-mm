Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 24FC86B00F4
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:04:47 -0400 (EDT)
Date: Wed, 18 Apr 2012 21:07:27 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
Message-ID: <20120418210727.0d113647@pyramind.ukuu.org.uk>
In-Reply-To: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

> 5) After running this on my system, the performance was improved quickly.
>=20
> 6) I performed the same experiment on our Samsung Smart phones as well. A=
nd I have seen a drastic improve in performance after running this for 3/4 =
times.
> =A0=A0=A0 In case of phones it is more helpful as there is no swap space.
>=20
> 7) Your feedback and suggestion is important. Based on the feedback, I ca=
n plan to submit the patches officially after performing basic cleanups.

So really I think this tells you two things

1. There are cases where the kernel paging subsystem is perhaps making
poor choices and should have forced out more read only pages.

2. For certain DMA allocation cases it might be a good idea to move the
interface out of the HIBERNATION config option and call it automatically
with the relevant memory allocator when requests for large linear
allocations would otherwise fail.

> This can be even using inside the multimedia drivers that requires large =
contiguous memory to check if that many memory pages can be reclaimed or no=
t.

Yes - I agree. However the way that the memory is obtained and the use of
shrink_all_memory() should not be exposed as it breaks the abstraction.

If you can use it *within* the contiguous memory allocator so that the
driver does not know about shrink_all_memory, then this would be
interesting and potentially useful.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
