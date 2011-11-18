Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3734F6B002D
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 16:26:55 -0500 (EST)
Received: by bke17 with SMTP id 17so5240597bke.14
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 13:26:51 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCHv17 0/11] Contiguous Memory Allocator
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <CA+K6fF6SH6BNoKgwArcqvyav4b=C5SGvymo5LS3akfD_yE_beg@mail.gmail.com>
Date: Fri, 18 Nov 2011 22:26:49 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v45u6zyy3l0zgt@mpn-glaptop>
In-Reply-To: <CA+K6fF6SH6BNoKgwArcqvyav4b=C5SGvymo5LS3akfD_yE_beg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, sandeep patil <psandeep.s@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave
 Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA
 Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 18 Nov 2011 22:20:48 +0100, sandeep patil <psandeep.s@gmail.com>=
 wrote:
> I am running a simple test to allocate contiguous regions and write a =
log on
> in a file on sdcard simultaneously. I can reproduce this migration fai=
lure 100%
> times with it.
> when I tracked the pages that failed to migrate, I found them on the
> buffer head lru
> list with a reference held on the buffer_head in the page, which
> causes drop_buffers()
> to fail.
>
> So, i guess my question is, until all the migration failures are
> tracked down and fixed,
> is there a plan to retry the contiguous allocation from a new range in=

> the CMA region?

No.  Current CMA implementation will stick to the same range of pages al=
so
on consequent allocations of the same size.

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
