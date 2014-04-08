Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id BACE66B0036
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 16:59:55 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so1131432eek.7
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 13:59:55 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id z42si4409072eel.2.2014.04.08.13.59.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 13:59:54 -0700 (PDT)
Message-ID: <5344631D.1050203@zytor.com>
Date: Tue, 08 Apr 2014 13:59:09 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>	<1396883443-11696-3-git-send-email-mgorman@suse.de>	<5342C517.2020305@citrix.com>	<20140407154935.GD7292@suse.de>	<20140407161910.GJ1444@moon>	<20140407182854.GH7292@suse.de>	<5342FC0E.9080701@zytor.com>	<20140407193646.GC23983@moon>	<5342FFB0.6010501@zytor.com>	<20140407212535.GJ7292@suse.de>	<CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com>	<e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com> <CAKbGBLjO7pneg_5nXcRXK-9iToZvPkJVZ=AQBfaZkZjU9iN2BA@mail.gmail.com>
In-Reply-To: <CAKbGBLjO7pneg_5nXcRXK-9iToZvPkJVZ=AQBfaZkZjU9iN2BA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Noonan <steven@uplinklabs.net>
Cc: Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On 04/08/2014 01:51 PM, Steven Noonan wrote:
> On Tue, Apr 8, 2014 at 8:16 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>> <snark>
>>
>> Of course, it would also be preferable if Amazon (or anything else) didn't need Xen PV :(
> 
> Well Amazon doesn't expose NUMA on PV, only on HVM guests.
> 

Yes, but Amazon is one of the main things keeping Xen PV alive as far as
I can tell, which means the support gets built in, and so on.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
