Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id CEE046B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 07:39:24 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so3123950pbc.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 04:39:24 -0700 (PDT)
Date: Fri, 23 Mar 2012 04:38:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC]swap: don't do discard if no discard option added
In-Reply-To: <alpine.LRH.2.02.1203211620480.21654@diagnostix.dwd.de>
Message-ID: <alpine.LSU.2.00.1203230424140.31745@eggly.anvils>
References: <4F68795E.9030304@kernel.org> <alpine.LSU.2.00.1203202019140.1842@eggly.anvils> <alpine.LRH.2.02.1203211620480.21654@diagnostix.dwd.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Holger Kiehl <Holger.Kiehl@dwd.de>
Cc: Shaohua Li <shli@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jason Mattax <jmattax@storytotell.org>, linux-mm@kvack.org

On Wed, 21 Mar 2012, Holger Kiehl wrote:
> On Tue, 20 Mar 2012, Hugh Dickins wrote:
> > 
> > It appears to be a bug in the Vertex 2: I did receive one other such
> > report on a Vertex 2 fourteen months ago, and in the absence of further
> > reports, we decided to consider that user's drive defective.  I wonder
> > if Holger's drive is defective, or if it's true of all Vertex 2s, or
> > if it depends on the firmware revision, and a later revision fixes it.
> > 
> I have three of those drives put together via MD to a raid 0 and I do
> not think they are defective, since they worked (without discard) so far.
> Firmware is also the new-es it's 1.35, just checked with OCZ website.

Thanks very much for checking and reporting back.

> 
> Thank you for the pointer with the firmware, I have posted a support
> question at OCZ.

Great: please let me know if they have anything of interest to add.

I've now ordered a Vertex2 myself, to see if it sheds any light on
what goes on.  Probably not; but my Vertex1 has recently started giving
errors, so I might as well use a 2 to replace it.  By the time I came
to investigate last year's report, the Vertex3 was imminent, so I
held on for that; but it turned out not to share the problem.

> > But if there's no good firmware for the Vertex 2, I'm not so sure
> > what to do: two reports in fourteen months, on a superseded drive -
> > is that strong enough to disable a feature which appeared to offer
> > some advantage on others?
> > 
> No, I agree that one should not disable a feature that is useful to so
> many, for the reasons you mention. However, it would be good if there
> is some way to disable this, other then having to always patch the kernel.

I should not exaggerate the effectiveness of the swapon at discard, on
any drive I tried: "useful to so many" is probably going too far.  I've
called the effect "slight": when I've time I shall measure again just
what that amounts to, and whether it's worth the effort of doing anything
cleverer than Shaohua's patch - quite possibly not.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
