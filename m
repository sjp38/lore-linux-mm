Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ED8B86B023F
	for <linux-mm@kvack.org>; Tue,  4 May 2010 13:36:15 -0400 (EDT)
Received: by bwz9 with SMTP id 9so2385189bwz.29
        for <linux-mm@kvack.org>; Tue, 04 May 2010 10:36:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100420230719.GB1432@n2100.arm.linux.org.uk>
References: <k2ncecb6d8f1004191627w3cd36450xf797f746460abb09@mail.gmail.com>
	<20100420155122.6f2c26eb.akpm@linux-foundation.org> <20100420230719.GB1432@n2100.arm.linux.org.uk>
From: Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br>
Date: Tue, 4 May 2010 14:35:50 -0300
Message-ID: <n2gcecb6d8f1005041035w51dac3c8ke829a4ae8bf7f408@mail.gmail.com>
Subject: Re: Suspicious compilation warning
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 20, 2010 at 20:07, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
>
> Well, it'll be about this number on everything using sparsemem extreme:
>
> #define SECTIONS_PER_ROOT =A0 =A0 =A0 (PAGE_SIZE / sizeof (struct mem_sec=
tion))
>
> and with only 32 sections, this is going to give a NR_SECTION_ROOTS value
> of zero. =A0I think the calculation of NR_SECTIONS_ROOTS is wrong.
>
> #define NR_SECTION_ROOTS =A0 =A0 =A0 =A0(NR_MEM_SECTIONS / SECTIONS_PER_R=
OOT)
>
> Clearly if we have 1 mem section, we want to have one section root, so
> I think this division should round up any fractional part, thusly:
>
> #define NR_SECTION_ROOTS =A0 =A0 =A0 =A0((NR_MEM_SECTIONS + SECTIONS_PER_=
ROOT - 1) / SECTIONS_PER_ROOT)

Seems correct to me, Is there any idea when this gets committed?

Regards,
Marcelo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
