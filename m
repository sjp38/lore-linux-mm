Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 865196B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 19:41:02 -0400 (EDT)
Received: by qyk32 with SMTP id 32so1391058qyk.14
        for <linux-mm@kvack.org>; Mon, 25 Jul 2011 16:41:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110725203705.GA21691@tassilo.jf.intel.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
	<1311625159-13771-5-git-send-email-jweiner@redhat.com>
	<20110725203705.GA21691@tassilo.jf.intel.com>
Date: Tue, 26 Jul 2011 08:40:59 +0900
Message-ID: <CAEwNFnARzetfqZqjh_9-d+FOHtrCEwaSxgqBy_D+apxsNqzqkg@mail.gmail.com>
Subject: Re: [patch 4/5] mm: writeback: throttle __GFP_WRITE on per-zone dirty limits
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org

Hi Andi,

On Tue, Jul 26, 2011 at 5:37 AM, Andi Kleen <ak@linux.intel.com> wrote:
>> The global dirty limits are put in proportion to the respective zone's
>> amount of dirtyable memory and the allocation denied when the limit of
>> that zone is reached.
>>
>> Before the allocation fails, the allocator slowpath has a stage before
>> compaction and reclaim, where the flusher threads are kicked and the
>> allocator ultimately has to wait for writeback if still none of the
>> zones has become eligible for allocation again in the meantime.
>>
>
> I don't really like this. It seems wrong to make memory
> placement depend on dirtyness.
>
> Just try to explain it to some system administrator or tuner: her
> head will explode and for good reasons.
>
> On the other hand I like doing round-robin in filemap by default
> (I think that is what your patch essentially does)
> We should have made =C2=A0this default long ago. It avoids most of the
> "IO fills up local node" problems people run into all the time.
>
> So I would rather just change the default in filemap allocation.
>
> That's also easy to explain.

Just out of curiosity.
Why do you want to consider only filemap allocation, not IO(ie,
filemap + sys_[read/write]) allocation?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
