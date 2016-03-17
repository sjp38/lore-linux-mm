Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D8D3D6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:13:33 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l124so75051315wmf.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 01:13:33 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id l125si9535442wmg.18.2016.03.17.01.13.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 01:13:32 -0700 (PDT)
Subject: Re: Page migration issue with UBIFS
References: <56E8192B.5030008@nod.at>
 <20160315151727.GA16462@node.shutemov.name> <56E82B18.9040807@nod.at>
 <20160315153744.GB28522@infradead.org> <56E8985A.1020509@nod.at>
 <20160316142156.GA23595@node.shutemov.name>
 <20160316142729.GA125481@black.fi.intel.com> <56E9C658.1020903@nod.at>
 <20160317071155.GB10315@js1304-P5Q-DELUXE>
From: Richard Weinberger <richard@nod.at>
Message-ID: <56EA672A.7070007@nod.at>
Date: Thu, 17 Mar 2016 09:13:30 +0100
MIME-Version: 1.0
In-Reply-To: <20160317071155.GB10315@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, Alexander Kaplan <alex@nextthing.co>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, rvaswani@codeaurora.org, "Luck, Tony" <tony.luck@intel.com>, Shailendra Verma <shailendra.capricorn@gmail.com>, s.strogin@partner.samsung.com

Am 17.03.2016 um 08:11 schrieb Joonsoo Kim:
>> It is still not clear why UBIFS has to provide a >migratepage() and what the expected semantics
>> are.
>> What we know so far is that the fall back migration function is broken. I'm sure not only on UBIFS.
>>
>> Can CMA folks please clarify? :-)
> 
> Hello,
> 
> As you mentioned earlier, this issue would not be directly related
> to CMA. It looks like it is more general issue related to interaction
> between MM and FS. Your first error log shows that error happens when
> ubifs_set_page_dirty() is called in try_to_unmap_one() which also
> can be called by reclaimer (kswapd or direct reclaim). Quick search shows
> that problem also happens on reclaim. Is that fixed?
> 
> http://www.spinics.net/lists/linux-fsdevel/msg79531.html

Well, this problem happened only on a tainted kernel and never popped up again.
So, I really don't know. :-)

> I think that you need to CC other people who understand interaction
> between MM and FS perfectly.

Who is missing on the CC list?

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
