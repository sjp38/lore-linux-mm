Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACF16B002F
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 09:42:02 -0400 (EDT)
Date: Tue, 18 Oct 2011 09:42:00 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: 3.1-rc9: BUG: soft lockup in find_get_pages+0x4e/0x140
In-Reply-To: <alpine.LSU.2.00.1110172036300.7358@sister.anvils>
Message-ID: <alpine.DEB.2.02.1110180806480.7942@p34.internal.lan>
References: <alpine.DEB.2.02.1110152003210.26507@p34.internal.lan> <alpine.LSU.2.00.1110172036300.7358@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pawel Sikora <pluto@agmk.net>, arekm@pld-linux.org, Anders Ossowicki <aowi@novozymes.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On Mon, 17 Oct 2011, Hugh Dickins wrote:

> On Sat, 15 Oct 2011, Justin Piszcz wrote:
>>
>> With 3.1-rc9 during a filesystem dump, this occurred, I thought a previous
>> patch fixed this but it did not, it occurs MUCH less (first time in a couple
>> of weeks) but the problem still occurs.
>
> Shaohua's nr_skip patch fixed, or at least worked around, the error I
> introduced there in 3.1-rc1.  But now you're finding a similar problem
> still in 3.1-rc9: that confirms what you and others already reported,
> that something like it occurs even in 3.0 without my bug.

Thanks,

Patch applied:

# patch -p1 < /tmp/memory_patch.patch
patching file mm/filemap.c
patching file mm/memcontrol.c

Now running 3.1-rc9 + this patch + re-enabled frame pointers.

Justin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
