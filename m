Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C9FC56B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 09:04:11 -0500 (EST)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDV00CGHWEWD7@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 23 Dec 2010 14:04:08 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDV00G7KWEVXX@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Dec 2010 14:04:08 +0000 (GMT)
Date: Thu, 23 Dec 2010 15:04:07 +0100
From: Tomasz Fujak <t.fujak@samsung.com>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
In-reply-to: <20101223134838.GK3636@n2100.arm.linux.org.uk>
Message-id: <4D1356D7.2000008@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
 <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
 <20101223100642.GD3636@n2100.arm.linux.org.uk>
 <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com>
 <20101223121917.GG3636@n2100.arm.linux.org.uk> <4D135004.3070904@samsung.com>
 <20101223134838.GK3636@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Kyungmin Park' <kmpark@infradead.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Ankita Garg' <ankita@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On 2010-12-23 14:48, Russell King - ARM Linux wrote:
> On Thu, Dec 23, 2010 at 02:35:00PM +0100, Tomasz Fujak wrote:
>> Dear Mr. King,
>>
>> AFAIK the CMA is the fourth attempt since 2008 taken to solve the
>> multimedia memory allocation issue on some embedded devices. Most
>> notably on ARM, that happens to be present in the SoCs we care about
>> along the IOMMU-incapable multimedia IPs.
>>
>> I understand that you have your guidelines taken from the ARM
>> specification, but this approach is not helping us.
> I'm sorry you feel like that, but I'm living in reality.  If we didn't
> have these architecture restrictions then we wouldn't have this problem
> in the first place.
Do we really have them, or just the documents say they exist?
> What I'm trying to do here is to ensure that we remain _legal_ to the
> architecture specification - which for this issue means that we avoid
> corrupting people's data.
As legal as the mentioned dma_coherent?
> Maybe you like having a system which randomly corrupts people's data?
> I most certainly don't.  But that's the way CMA is heading at the moment
> on ARM.
Has this been experienced? I had some ARM-compatible boards on my desk
(xscale, v6 and v7) and none of them crashed due to this behavior. And
we *do* have multiple memory mappings, with different attributes.
> It is not up to me to solve these problems - that's for the proposer of
> the new API to do so.  So, please, don't try to lump this problem on
> my shoulders.  It's not my problem to sort out.
Just great. Nothing short of spectacular - this way the IA32 is going to
take the embedded market piece by piece once the big two advance their
foundry processes.
Despite having the translator, so much burden in the legacy ISA and the
fact that most of the embedded engineers from the high end are
accustomed to the ARM.

In other words, should we take your response as yet another NAK?
Or would you try harder and at least point us to some direction that
would not doom the effort from the very beginning.
I understand that the role of an oracle is so much easier, but the time
is running and devising subsequent solutions is not the use of
engineers' time.

Best regards
---
Tomasz Fujak

> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
