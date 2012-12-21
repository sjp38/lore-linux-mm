Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 216EF6B006C
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 16:51:48 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id t57so2399721wey.11
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 13:51:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1212210944050.1699@eggly.anvils>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <1353624594-1118-19-git-send-email-mingo@kernel.org> <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
 <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
 <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com>
 <20121221134740.GC13367@suse.de> <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
 <alpine.LNX.2.00.1212210944050.1699@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 21 Dec 2012 13:51:26 -0800
Message-ID: <CA+55aFwUpuLgeyBNBD64Qy3iBhRz5-8F6z+V3WZXXvY7khnp_A@mail.gmail.com>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <levinsasha928@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Dec 21, 2012 at 10:21 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 21 Dec 2012, Linus Torvalds wrote:
>>
>> compared to the diseased abortion you just posted.
>
> I'm picking up a vibe that you don't entirely like Mel's approach.

Good job. I was a bit nervous that I was being too subtle.

> I don't understand David's and Mel's remarks about the "shared pages"
> check making Sasha's warning unlikely: page_mapcount has nothing to do
> with whether a page belongs to shm/shmem/tmpfs, and it's easy enough
> to reproduce Sasha's warning on the current git tree.  "mount -o
> remount,mpol=local /tmp" or something like that is useful in testing.

I think that Mel and David may talk about the mutex actually blocking
(not just the debug message possibly triggering).

> I wish wish wish I had time to spend on this today, but I don't.
> And I've not looked to see (let alone tested) whether it's easy
> to revert Mel's mutex then add in Kosaki's patch (which I didn't
> look at so have no opinion on).

I don't actually have Kosaki's patch either, just the description of
it. We've done that kind of "preallocate before taking the lock"
before, though.

> Shall we go for Peter/David's mutex+spinlock for rc1 - I assume
> they both tested that - with a promise to do better in rc2?

Well, if the plan is to fix it for rc2, then there is no point in
putting a workaround in now, since actually hitting the problem (as
opposed to seeing the warning) is presumably much harder.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
