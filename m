Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF946B0035
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:18:18 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so893056eek.3
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:18:17 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id u5si3421205een.113.2014.04.08.09.18.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 09:18:16 -0700 (PDT)
Message-ID: <534420F1.3030301@zytor.com>
Date: Tue, 08 Apr 2014 09:16:49 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
References: <5342C517.2020305@citrix.com> <20140407154935.GD7292@suse.de> <20140407161910.GJ1444@moon> <20140407182854.GH7292@suse.de> <5342FC0E.9080701@zytor.com> <20140407193646.GC23983@moon> <5342FFB0.6010501@zytor.com> <20140407212535.GJ7292@suse.de> <CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com> <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com> <20140408160250.GE31554@phenom.dumpdata.com>
In-Reply-To: <20140408160250.GE31554@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Steven Noonan <steven@uplinklabs.net>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On 04/08/2014 09:02 AM, Konrad Rzeszutek Wilk wrote:
>>>
>>> Amazon EC2 does have large memory instance types with NUMA exposed to
>>> the guest (e.g. c3.8xlarge, i2.8xlarge, etc), so it'd be preferable
>>> (to me anyway) if we didn't require !XEN.
> 
> What about the patch that David Vrabel posted:
> 
> http://osdir.com/ml/general/2014-03/msg41979.html
> 
> Has anybody taken it for a spin?
> 

Oh lovely, more pvops in low level paths.  I'm so thrilled.

Incidentally, I wasn't even Cc:'d on that patch and was only added to
the thread by Linus, but never saw the early bits of the thread
including the actual patch.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
