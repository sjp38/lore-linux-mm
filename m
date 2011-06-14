Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 02D2A6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 14:58:27 -0400 (EDT)
Received: by fxm18 with SMTP id 18so5647760fxm.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 11:58:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110614170158.GU2419@fooishbar.org>
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
	<201106141549.29315.arnd@arndb.de>
	<op.vw2jmhir3l0zgt@mnazarewicz-glaptop>
	<201106141803.00876.arnd@arndb.de>
	<20110614170158.GU2419@fooishbar.org>
Date: Tue, 14 Jun 2011 13:58:25 -0500
Message-ID: <BANLkTi=cJisuP8=_YSg4h-nsjGj3zsM7sg@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory
 Allocator added
From: Zach Pfeffer <zach.pfeffer@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Stone <daniels@collabora.com>, Arnd Bergmann <arnd@arndb.de>, Michal Nazarewicz <mina86@mina86.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On 14 June 2011 12:01, Daniel Stone <daniels@collabora.com> wrote:
> Hi,
>
> On Tue, Jun 14, 2011 at 06:03:00PM +0200, Arnd Bergmann wrote:
>> On Tuesday 14 June 2011, Michal Nazarewicz wrote:
>> > On Tue, 14 Jun 2011 15:49:29 +0200, Arnd Bergmann <arnd@arndb.de> wrot=
e:
>> > > Please explain the exact requirements that lead you to defining mult=
iple
>> > > contexts.
>> >
>> > Some devices may have access only to some banks of memory. =A0Some dev=
ices
>> > may use different banks of memory for different purposes.
>>
>> For all I know, that is something that is only true for a few very speci=
al
>> Samsung devices, and is completely unrelated of the need for contiguous
>> allocations, so this approach becomes pointless as soon as the next
>> generation of that chip grows an IOMMU, where we don't handle the specia=
l
>> bank attributes. Also, the way I understood the situation for the Samsun=
g
>> SoC during the Budapest discussion, it's only a performance hack, not a
>> functional requirement, unless you count '1080p playback' as a functiona=
l
>> requirement.

Coming in mid topic...

I've seen this split bank allocation in Qualcomm and TI SoCs, with
Samsung, that makes 3 major SoC vendors (I would be surprised if
Nvidia didn't also need to do this) - so I think some configurable
method to control allocations is necessarily. The chips can't do
decode without it (and by can't do I mean 1080P and higher decode is
not functionally useful). Far from special, this would appear to be
the default.

> Hm, I think that was something similar but not quite the same: talking
> about having allocations split to lie between two banks of RAM to
> maximise the read/write speed for performance reasons. =A0That's somethin=
g
> that can be handled in the allocator, rather than an API constraint, as
> this is.
>
> Not that I know of any hardware which is limited as such, but eh.
>
> Cheers,
> Daniel
>
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
