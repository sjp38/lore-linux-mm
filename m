Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 84A2C6B007B
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 19:36:58 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id hm2so3094523wib.16
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 16:36:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121221231024.GG13367@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <1353624594-1118-19-git-send-email-mingo@kernel.org> <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
 <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
 <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com>
 <20121221134740.GC13367@suse.de> <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
 <20121221195817.GE13367@suse.de> <CA+55aFwDXj3LqCRepsaeZMjOg0YsWV=7GFLHqHe2CxoF4JchCQ@mail.gmail.com>
 <20121221231024.GG13367@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 21 Dec 2012 16:36:36 -0800
Message-ID: <CA+55aFza356-L4F2RC1UP3ujDLoTU2352s3o171mQOQHJRaktw@mail.gmail.com>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Ok, this looks fine to me, but I'd like to get a sign-off from Kosaki
too, and I guess it's really not all that urgent, so I can do the -rc1
release tonight without worrying about it, knowing that a fix is at
least pending, and that nobody is likely to actually ever hit the
problem in practice anyway.

             Linus

On Fri, Dec 21, 2012 at 3:10 PM, Mel Gorman <mgorman@suse.de> wrote:
>
> mm: mempolicy: Convert shared_policy mutex to spinlock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
