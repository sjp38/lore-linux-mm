Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id A2B9390001D
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 21:10:37 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id x19so12743547ier.19
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 18:10:37 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id y8si34524105icl.32.2014.11.11.18.10.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 18:10:36 -0800 (PST)
Received: by mail-ig0-f174.google.com with SMTP id hn18so2164651igb.1
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 18:10:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141111142344.b4eb11c6e3c240d345fdd995@linux-foundation.org>
References: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
	<20141111142344.b4eb11c6e3c240d345fdd995@linux-foundation.org>
Date: Wed, 12 Nov 2014 10:10:36 +0800
Message-ID: <CAL1ERfO5GNanwLkL36b11NDUTptzGrxVF=rN913bHjS9wFNWKQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: page_isolation: check pfn validity before access
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, kamezawa.hiroyu@jp.fujitsu.com, Minchan Kim <minchan@kernel.org>, mgorman@suse.de, mina86@mina86.com, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, isimatu.yasuaki@jp.fujitsu.com

On Wed, Nov 12, 2014 at 6:23 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 06 Nov 2014 16:08:02 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:
>
>> In the undo path of start_isolate_page_range(), we need to check
>> the pfn validity before access its page, or it will trigger an
>> addressing exception if there is hole in the zone.
>>
>
> There is not enough information in the chagnelog for me to decide how
> to handle the patch.  3.19?  3.18? 3.18+stable?
>
> When fixing bugs, please remember to fully explain the end-user impact
> of the bug.  Under what circumstances does it occur?

I'm sorry to disturb you. This issue is found by code-review not a test-trigger.
In "CONFIG_HOLES_IN_ZONE" environment, there is a certain chance that
it would casue an addressing exception when start_isolate_page_range() fails,
this could affect CMA, hugepage and memory-hotplug function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
