Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 66AC06B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 04:21:23 -0500 (EST)
Received: by eekc13 with SMTP id c13so129186eek.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 01:21:21 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCH 11/15] mm: trigger page reclaim in
 alloc_contig_range() to stabilize watermarks
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-12-git-send-email-m.szyprowski@samsung.com>
 <20120203140428.GG5796@csn.ul.ie>
 <CA+K6fF49BQiNer=7Di+gCU_EX4E41q-teXJJUBjEd2xc12-j4w@mail.gmail.com>
Date: Wed, 08 Feb 2012 10:21:18 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9cr9sqm3l0zgt@mpn-glaptop>
In-Reply-To: <CA+K6fF49BQiNer=7Di+gCU_EX4E41q-teXJJUBjEd2xc12-j4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, sandeep patil <psandeep.s@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Wed, 08 Feb 2012 03:04:18 +0100, sandeep patil <psandeep.s@gmail.com>=
 wrote:
> There's another problem I am facing with zone watermarks and CMA.
>
> Test details:
> Memory  : 480 MB of total memory, 128 MB CMA region
> Test case : around 600 MB of file transfer over USB RNDIS onto target
> System Load : ftpd with console running on target.
> No one is doing CMA allocations except for the DMA allocations done by=
 the
> drivers.
>
> Result : After about 300MB transfer, I start getting GFP_ATOMIC
> allocation failures.  This only happens if CMA region is reserved.

[...]

> Total memory available is way above the zone watermarks. So, we ended
> up starving
> UNMOVABLE/RECLAIMABLE atomic allocations that cannot fallback on CMA r=
egion.

This looks like something Mel warned me about.  I don't really have a go=
od
solution for that yet. ;/

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
