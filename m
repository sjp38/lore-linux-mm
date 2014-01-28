Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0CABE6B0037
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:42:50 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so835812pab.18
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 12:42:50 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id y1si16712689pbm.244.2014.01.28.12.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 12:42:49 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id p10so815165pdj.29
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 12:42:48 -0800 (PST)
Date: Tue, 28 Jan 2014 12:42:08 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [LSF/MM ATTEND] persistent transparent large
In-Reply-To: <20140128193833.GD20939@parisc-linux.org>
Message-ID: <alpine.LSU.2.11.1401281213490.1633@eggly.anvils>
References: <alpine.LSU.2.11.1401230334110.1414@eggly.anvils> <20140128193833.GD20939@parisc-linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, 28 Jan 2014, Matthew Wilcox wrote:
> On Thu, Jan 23, 2014 at 04:23:04AM -0800, Hugh Dickins wrote:
> > I'm eager to participate in this year's LSF/MM, but no topics of my
> > own to propose: I need to listen to what other people are suggesting.
> > 
> > Topics of most interest to me span mm and fs: persistent memory and
> > xip, transparent huge pagecache, large sectors, mm scalability.
> 
> I don't want to particularly pick on Hugh here; indeed, I know he won't
> take it personally which is why I've chosen to respoond to Hugh's message

Sure, your remarks are completely appropriate, and very well directed.

> rather than any of the others.  I'm rather annoyed at the huge disrepancy
> between the number of people who are *saying* they're interested in
> persistent memory and the number of people who are reviewing patches
> relating to persistent memory.

It's fair enough, though, for people to express an interest in a topic,
without having time to contribute to it beforehand.  That does not earn
anyone a place, but may help the committee to choose between topics.

Frustrating for you, though; and for everyone else pushing a patchset.

> 
> As far as I'm concerned, the only people who have "earned" their way into
> attending the Summit based on contributing to persistent memory work
> would be Dave Chinner (er ... on the ctte already), Ted Ts'o (ditto),
> Jan Kara (ditto), Kirill Shutemov, Dave Hansen (who's not looking to
> attend this year), Ross Zwisler (ditto), and Andreas Dilger.

It might be a good idea to insist on significant review contributions
in relevant areas as a condition for attendance.  That's a matter for
the committee to decide (I expect it's already taken into account),
but it should help to improve our review rate.

Counts me out, but that's okay.

> 
> I'd particularly like a VM person to review these two patches:
> 
> http://marc.info/?l=linux-fsdevel&m=138983598101510&w=2
> http://marc.info/?l=linux-fsdevel&m=138983600001513&w=2

I'd love to give you a constructive answer, but I'm not going to
comment on 2 out of 22 without getting to grips with the 22.  You've
been thinking about this stuff for months: others need time too,
and this is far from the only patchset on their queues.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
