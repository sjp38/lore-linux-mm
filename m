Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AF2BE6B02A6
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 21:10:02 -0400 (EDT)
Received: by qwk4 with SMTP id 4so4343122qwk.14
        for <linux-mm@kvack.org>; Wed, 04 Aug 2010 18:10:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimejYX3OEk9j+L+nWKyBuf7=rJbAOvQGhxJNPxN@mail.gmail.com>
References: <AANLkTi=1DxqLrqVbfRouOBRWg4RHFaHz438X7F1JWL6P@mail.gmail.com>
	<AANLkTimejYX3OEk9j+L+nWKyBuf7=rJbAOvQGhxJNPxN@mail.gmail.com>
Date: Thu, 5 Aug 2010 09:10:21 +0800
Message-ID: <AANLkTi=5Ks0jmnGgUzH_gPEt36KPK7mwfdMscw8yTPmc@mail.gmail.com>
Subject: Re: question about CONFIG_BASE_SMALL
From: Pei Lin <telent997@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Cc: Ryan Wang <openspace.wang@gmail.com>, kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2010/8/4 Mulyadi Santosa <mulyadi.santosa@gmail.com>:
> Hi...
>
> On Wed, Aug 4, 2010 at 15:38, Ryan Wang <openspace.wang@gmail.com> wrote:
>> Hi all,
>>
>> =A0 =A0 =A0I noticed CONFIG_BASE_SMALL in different parts
>> of the kernel code, with ifdef/ifndef.
>> =A0 =A0 =A0I wonder what does CONFIG_BASE_SMALL mean?
>> And how can I configure it, e.g. through make menuconfig?
>
> Reply on top of my head: IIRC it means to disable certain things...or
> possibly enabling things that might reduce memory footprints.
>
> The goal....to make Linux kernel running more suitable for embedded
> system and low level specification machine...
>
FYI.

Date:	Mon, 31 Jan 2005 01:25:51 -0600
To: Andrew Morton <akpm@osdl.org>

This patch series introduced a new pair of CONFIG_EMBEDDED options call
CONFIG_BASE_FULL/CONFIG_BASE_SMALL. Disabling CONFIG_BASE_FULL sets
the boolean CONFIG_BASE_SMALL to 1 and it is used to shrink a number
of core data structures. The space savings for the current batch is
around 14k.
-

For example , look at the file "Linux/include/linux/udp.h"
http://lxr.free-electrons.com/source/include/linux/udp.h

#define UDP_HTABLE_SIZE_MIN             (CONFIG_BASE_SMALL ? 128 : 256)


> --
> regards,
>
> Mulyadi Santosa
> Freelance Linux trainer and consultant
>
> blog: the-hydra.blogspot.com
> training: mulyaditraining.blogspot.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>



--=20
Best Regards
Lin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
