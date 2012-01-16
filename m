Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 1BADB6B0075
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:48:15 -0500 (EST)
Received: by werl4 with SMTP id l4so797774wer.14
        for <linux-mm@kvack.org>; Mon, 16 Jan 2012 04:48:13 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 04/11] mm: page_alloc: introduce alloc_contig_range()
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-5-git-send-email-m.szyprowski@samsung.com>
 <20120110141613.GB3910@csn.ul.ie> <op.v71gpt1b3l0zgt@mpn-glaptop>
 <20120116090110.GA2929@csn.ul.ie>
Date: Mon, 16 Jan 2012 13:48:11 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v76giluf3l0zgt@mpn-glaptop>
In-Reply-To: <20120116090110.GA2929@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Mon, 16 Jan 2012 10:01:10 +0100, Mel Gorman <mel@csn.ul.ie> wrote:

> On Fri, Jan 13, 2012 at 09:04:31PM +0100, Michal Nazarewicz wrote:
>> >On Thu, Dec 29, 2011 at 01:39:05PM +0100, Marek Szyprowski wrote:
>> >>From: Michal Nazarewicz <mina86@mina86.com>
>> >>+	/* Make sure all pages are isolated. */
>> >>+	if (!ret) {
>> >>+		lru_add_drain_all();
>> >>+		drain_all_pages();
>> >>+		if (WARN_ON(test_pages_isolated(start, end)))
>> >>+			ret =3D -EBUSY;
>> >>+	}
>>
>> On Tue, 10 Jan 2012 15:16:13 +0100, Mel Gorman <mel@csn.ul.ie> wrote:=

>> >Another global IPI seems overkill. Drain pages only from the local C=
PU
>> >(drain_pages(get_cpu()); put_cpu()) and test if the pages are isolat=
ed.
>>
>> Is get_cpu() + put_cpu() required? Won't drain_local_pages() work?
>>
>
> drain_local_pages() calls smp_processor_id() without preemption
> disabled.

Thanks, I wasn't sure if preemption is an issue.

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
