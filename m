Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8BD8D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 20:42:21 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p2V0gJnX004868
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 17:42:19 -0700
Received: from ywo32 (ywo32.prod.google.com [10.192.15.32])
	by wpaz1.hot.corp.google.com with ESMTP id p2V0g58v014023
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 17:42:18 -0700
Received: by ywo32 with SMTP id 32so984720ywo.7
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 17:42:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110330164906.GE12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
	<4D91FC2D.4090602@redhat.com>
	<20110329190520.GJ12265@random.random>
	<BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
	<20110330161716.GA3876@csn.ul.ie>
	<20110330164906.GE12265@random.random>
Date: Wed, 30 Mar 2011 17:42:15 -0700
Message-ID: <BANLkTinH5Gr+-n4MAUsxthQ_mXA-8jkw0w@mail.gmail.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>

On Wed, Mar 30, 2011 at 9:49 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Wed, Mar 30, 2011 at 05:17:16PM +0100, Mel Gorman wrote:
>> I'd prefer to see OOM-related issues treated as a separate-but-related
>> problem if possible so;
>
> I prefer it too. The OOM killing is already covered in OOM topic from
> Hugh, and we can add "OOM detection latency" to it.

Thanks for adjusting and updating the schedule, Andrea.  I'm way
behind in my mailbox and everything else, that was a real help.

But last night I did remove that OOM and fork-bomb topic you
mischievously added in my name ;-)  Yes, I did propose an OOM topic
against my name in the working list I sent you a few days ago, but by
Monday had concluded that it would be pretty silly for me to get up
and spout the few things I have to say about it, in the absence of
every one of the people most closely involved and experienced.  And on
fork-bombs I've even less to say.

Of course, none of these sessions are for those named facilitators to
lecture the assembled company for half an hour.  We can bring it back
it there's demand on the day: but right now I'd prefer to keep it as
an empty slot, to be decided when the time comes.  After all, those FS
people, they appear to thrive on empty slots!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
