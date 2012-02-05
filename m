Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id AD7976B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 09:33:15 -0500 (EST)
Received: by eekc13 with SMTP id c13so2094143eek.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 06:33:14 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 12/15] drivers: add Contiguous Memory Allocator
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-13-git-send-email-m.szyprowski@samsung.com>
 <CAJd=RBBPOwftZJUfe3xc6y24=T8un5hPk0wEOT_5v6WMCbDSag@mail.gmail.com>
Date: Sun, 05 Feb 2012 15:33:08 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v87mpive3l0zgt@mpn-glaptop>
In-Reply-To: <CAJd=RBBPOwftZJUfe3xc6y24=T8un5hPk0wEOT_5v6WMCbDSag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Hillf Danton <dhillf@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, 05 Feb 2012 05:25:40 +0100, Hillf Danton <dhillf@gmail.com> wrot=
e:
> Without boot mem reservation, what is the successful rate of CMA to
> serve requests of 1MiB, 2MiB, 4MiB and 8MiB chunks?

CMA will work as long as you manage to get some pageblocks marked as
MIGRATE_CMA and move all non-movable pages away.  You might try and get =
it
done after system has booted but we have not tried nor tested it.
Reservation at boot time lets us make sure that the portion of memory we=

are grabbing has no unmovable pages.

You might still and use alloc_contig_pages() on its own (even without
MIGRATE_CMA) but that would require additional code which would look for=

a region of memory that could be used (ie. that does not have unmovable
pages in it).  That in fact was what Kamezawa's code was doing.

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
