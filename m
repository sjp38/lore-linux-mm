Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 77ABF6B0194
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 10:46:14 -0500 (EST)
Received: by bkbzt12 with SMTP id zt12so7040826bkb.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 07:46:12 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 04/11] mm: compaction: export some of the functions
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-5-git-send-email-m.szyprowski@samsung.com>
 <20111212142906.GE3277@csn.ul.ie> <op.v6dseqji3l0zgt@mpn-glaptop>
 <20111212154015.GI3277@csn.ul.ie>
Date: Mon, 12 Dec 2011 16:46:10 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6dve8mo3l0zgt@mpn-glaptop>
In-Reply-To: <20111212154015.GI3277@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse
 Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

>> On Mon, 12 Dec 2011 15:29:07 +0100, Mel Gorman <mel@csn.ul.ie> wrote:=

>>> Overall, this patch implies that CMA is always compiled in.

> On Mon, Dec 12, 2011 at 03:41:04PM +0100, Michal Nazarewicz wrote:
>> Not really.  But yes, it produces some bloat when neither CMA nor
>> compaction are compiled.  I assume that linker will be able to deal
>> with that (since the functions are not EXPORT_SYMBOL'ed).

On Mon, 12 Dec 2011 16:40:15 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> The bloat exists either way. I don't believe the linker strips it out =
so
> overall it would make more sense to depend on compaction to keep the
> vmstat counters for debugging reasons if nothing else. It's not
> something I feel very strongly about though.

KK, I'll do that then.

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
