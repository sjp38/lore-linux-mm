Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 851056B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 11:59:05 -0500 (EST)
Received: by eyh6 with SMTP id 6so3470764eyh.14
        for <linux-mm@kvack.org>; Tue, 04 Jan 2011 08:59:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <C832F8F5D375BD43BFA11E82E0FE9FE00829C13EB2@EXDCVYMBSTM005.EQ1STM.local>
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
	<AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
	<20101223100642.GD3636@n2100.arm.linux.org.uk>
	<C832F8F5D375BD43BFA11E82E0FE9FE00829C13EB2@EXDCVYMBSTM005.EQ1STM.local>
Date: Tue, 4 Jan 2011 17:59:01 +0100
Message-ID: <AANLkTim38-vyKzKg8UDzffX2jWAJrgQNJZd=rd7gbpCc@mail.gmail.com>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
From: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <mina86@mina86.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Johan MOSSBERG <johan.xx.mossberg@stericsson.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Kyungmin Park <kmpark@infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

> Russell King wrote:
>> Has anyone addressed my issue with it that this is wide-open for
>> abuse by allocating large chunks of memory, and then remapping
>> them in some way with different attributes, thereby violating the
>> ARM architecture specification?

2011/1/4 Johan MOSSBERG <johan.xx.mossberg@stericsson.com>:
> Where in the specification (preferably ARMv7) can I find
> information about this? Is the problem that it is simply
> forbidden to map an address multiple times with different cache
> setting and if this is done the hardware might start failing? Or
> is the problem that having an address mapped cached means that
> speculative pre-fetch can read it into the cache at any time,
> possibly causing problems if an un-cached mapping exists?

IIRC both apply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
