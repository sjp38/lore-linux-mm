Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B73968D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:16:15 -0400 (EDT)
Date: Thu, 31 Mar 2011 17:15:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110331151541.GF12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
 <20110329190520.GJ12265@random.random>
 <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
 <20110330161716.GA3876@csn.ul.ie>
 <20110330164906.GE12265@random.random>
 <BANLkTinH5Gr+-n4MAUsxthQ_mXA-8jkw0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTinH5Gr+-n4MAUsxthQ_mXA-8jkw0w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>

On Wed, Mar 30, 2011 at 05:42:15PM -0700, Hugh Dickins wrote:
> On Wed, Mar 30, 2011 at 9:49 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > On Wed, Mar 30, 2011 at 05:17:16PM +0100, Mel Gorman wrote:
> >> I'd prefer to see OOM-related issues treated as a separate-but-related
> >> problem if possible so;
> >
> > I prefer it too. The OOM killing is already covered in OOM topic from
> > Hugh, and we can add "OOM detection latency" to it.
> 
> Thanks for adjusting and updating the schedule, Andrea.  I'm way
> behind in my mailbox and everything else, that was a real help.

Glad I could help.

> But last night I did remove that OOM and fork-bomb topic you
> mischievously added in my name ;-)  Yes, I did propose an OOM topic
> against my name in the working list I sent you a few days ago, but by
> Monday had concluded that it would be pretty silly for me to get up
> and spout the few things I have to say about it, in the absence of
> every one of the people most closely involved and experienced.  And on
> fork-bombs I've even less to say.
>
> Of course, none of these sessions are for those named facilitators to
> lecture the assembled company for half an hour.  We can bring it back
> it there's demand on the day: but right now I'd prefer to keep it as
> an empty slot, to be decided when the time comes.  After all, those FS
> people, they appear to thrive on empty slots!

Ok, and agree that the MM track is pretty dense already ;).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
