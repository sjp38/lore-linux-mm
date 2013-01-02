Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 85AD26B005D
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 14:44:08 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id d13so6072351eaa.35
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 11:44:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFza356-L4F2RC1UP3ujDLoTU2352s3o171mQOQHJRaktw@mail.gmail.com>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <1353624594-1118-19-git-send-email-mingo@kernel.org> <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
 <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
 <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com>
 <20121221134740.GC13367@suse.de> <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
 <20121221195817.GE13367@suse.de> <CA+55aFwDXj3LqCRepsaeZMjOg0YsWV=7GFLHqHe2CxoF4JchCQ@mail.gmail.com>
 <20121221231024.GG13367@suse.de> <CA+55aFza356-L4F2RC1UP3ujDLoTU2352s3o171mQOQHJRaktw@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 2 Jan 2013 14:43:46 -0500
Message-ID: <CAHGf_=o7PBt1y=nBFqH17zoY+Wj1mzQm3XJLSNKG1s0_XCCcNw@mail.gmail.com>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>

> Ok, this looks fine to me, but I'd like to get a sign-off from Kosaki
> too, and I guess it's really not all that urgent, so I can do the -rc1
> release tonight without worrying about it, knowing that a fix is at
> least pending, and that nobody is likely to actually ever hit the
> problem in practice anyway.

Sorry for the looooong time silince. I broke my stomach and I didn't actively
developed last year. I apologize this.

Anyway, I ran basic tests of mempolicy again and I have no seen any
failure. Thus

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
