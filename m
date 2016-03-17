Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id D52BF6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 11:17:19 -0400 (EDT)
Received: by mail-oi0-f46.google.com with SMTP id r187so65954462oih.3
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:17:19 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id r125si6487195oib.52.2016.03.17.08.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 08:17:18 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id w20so10347736oia.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:17:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56EA672A.7070007@nod.at>
References: <56E8192B.5030008@nod.at>
	<20160315151727.GA16462@node.shutemov.name>
	<56E82B18.9040807@nod.at>
	<20160315153744.GB28522@infradead.org>
	<56E8985A.1020509@nod.at>
	<20160316142156.GA23595@node.shutemov.name>
	<20160316142729.GA125481@black.fi.intel.com>
	<56E9C658.1020903@nod.at>
	<20160317071155.GB10315@js1304-P5Q-DELUXE>
	<56EA672A.7070007@nod.at>
Date: Fri, 18 Mar 2016 00:17:18 +0900
Message-ID: <CAAmzW4M2uLE0VJ91BfveNR4_crsaUEPpLB6HW393jhpF4=G73Q@mail.gmail.com>
Subject: Re: Page migration issue with UBIFS
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, Alexander Kaplan <alex@nextthing.co>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, rvaswani@codeaurora.org, "Luck, Tony" <tony.luck@intel.com>, Shailendra Verma <shailendra.capricorn@gmail.com>, s.strogin@partner.samsung.com, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

2016-03-17 17:13 GMT+09:00 Richard Weinberger <richard@nod.at>:
> Am 17.03.2016 um 08:11 schrieb Joonsoo Kim:
>>> It is still not clear why UBIFS has to provide a >migratepage() and what the expected semantics
>>> are.
>>> What we know so far is that the fall back migration function is broken. I'm sure not only on UBIFS.
>>>
>>> Can CMA folks please clarify? :-)
>>
>> Hello,
>>
>> As you mentioned earlier, this issue would not be directly related
>> to CMA. It looks like it is more general issue related to interaction
>> between MM and FS. Your first error log shows that error happens when
>> ubifs_set_page_dirty() is called in try_to_unmap_one() which also
>> can be called by reclaimer (kswapd or direct reclaim). Quick search shows
>> that problem also happens on reclaim. Is that fixed?
>>
>> http://www.spinics.net/lists/linux-fsdevel/msg79531.html
>
> Well, this problem happened only on a tainted kernel and never popped up again.
> So, I really don't know. :-)
>
>> I think that you need to CC other people who understand interaction
>> between MM and FS perfectly.
>
> Who is missing on the CC list?

Vlastimil already added Hugh and Mel to other relevant thread but I think
this thread has more information about the problem so I add them here.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
