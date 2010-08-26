Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E40676B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 05:36:26 -0400 (EDT)
Received: by iwn33 with SMTP id 33so1890620iwn.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 02:36:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100826133028.39d731da.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	<1282310110.2605.976.camel@laptop>
	<20100825155814.25c783c7.akpm@linux-foundation.org>
	<20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
	<op.vh0wektv7p4s8u@localhost>
	<20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
	<20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=T1y+sQuqVTYgOkYvqrxdYB1bZmCpKafN5jPqi@mail.gmail.com>
	<20100826133028.39d731da.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 Aug 2010 18:36:24 +0900
Message-ID: <AANLkTimB+s0tO=wrODAU4qCaZnCBoLZ2A9pGjR_jheOj@mail.gmail.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: =?ISO-8859-2?Q?Micha=B3_Nazarewicz?= <m.nazarewicz@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 1:30 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 26 Aug 2010 13:06:28 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Thu, Aug 26, 2010 at 12:44 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Thu, 26 Aug 2010 11:50:17 +0900
>> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> >> 128MB...too big ? But it's depend on config.
>> >>
>> >> IBM's ppc guys used 16MB section, and recently, a new interface to sh=
rink
>> >> the number of /sys files are added, maybe usable.
>> >>
>> >> Something good with this approach will be you can create "cma" memory
>> >> before installing driver.
>> >>
>> >> But yes, complicated and need some works.
>> >>
>> > Ah, I need to clarify what I want to say.
>> >
>> > With compaction, it's helpful, but you can't get contiguous memory lar=
ger
>> > than MAX_ORDER, I think. To get memory larger than MAX_ORDER on demand=
,
>> > memory hot-plug code has almost all necessary things.
>>
>> True. Doesn't patch's idea of Christoph helps this ?
>> http://lwn.net/Articles/200699/
>>
>
> yes, I think so. But, IIRC, =A0it's own purpose of Chirstoph's work is
> for removing zones. please be careful what's really necessary.

Ahh. Sorry for missing point.
You're right. The patch can't help our problem.

How about changing following this?
The thing is MAX_ORDER is static. But we want to avoid too big
MAX_ORDER of whole zones to support devices which requires big
allocation chunk.
So let's add MAX_ORDER into each zone and then, each zone can have
different max order.
For example, while DMA[32], NORMAL, HIGHMEM can have normal size 11,
MOVABLE zone could have a 15.

This approach has a big side effect?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
