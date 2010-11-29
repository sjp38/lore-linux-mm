Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A4E1D6B004A
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 23:30:30 -0500 (EST)
Received: by iwn9 with SMTP id 9so490308iwn.14
        for <linux-mm@kvack.org>; Sun, 28 Nov 2010 20:30:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4CF32BD5.8050006@redhat.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
	<48315b5fe54efa08982aa7df77e8abe793889e3a.1290956059.git.minchan.kim@gmail.com>
	<4CF32BD5.8050006@redhat.com>
Date: Mon, 29 Nov 2010 13:30:28 +0900
Message-ID: <AANLkTinr0UtYzptXzZXB4hu_XvF8BzY86GiQE=b+zsj1@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] Prevent promotion of page in madvise_dontneed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 1:28 PM, Rik van Riel <riel@redhat.com> wrote:
> On 11/28/2010 10:02 AM, Minchan Kim wrote:
>>
>> Now zap_pte_range alwayas promotes pages which are pte_young&&
>> !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
>> it's unnecessary since the page wouldn't use any more.
>>
>> If the page is sharred by other processes and it's real working set
>
> This line seems to be superfluous, I don't see any special
> treatment for this case in the code.

I should remove the lines.
It's my fault.

>
>> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
>> Cc: Rik van Riel<riel@redhat.com>
>> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>> Cc: Johannes Weiner<hannes@cmpxchg.org>
>> Cc: Nick Piggin<npiggin@kernel.dk>
>> Cc: Mel Gorman<mel@csn.ul.ie>
>> Cc: Wu Fengguang<fengguang.wu@intel.com>
>
> The patch itself looks good to me.
>
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks, Rik.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
