Date: Wed, 11 Jun 2003 21:07:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: How to fix the total size of buffer caches in 2.4.5?
Message-ID: <20030612040730.GX15692@holomorphy.com>
References: <20030611162224.GR15692@holomorphy.com> <Pine.LNX.4.44.0306111226160.1656-100000@ickis.cs.wm.edu> <20030611165017.GS15692@holomorphy.com> <20030611233626.A30212@algol.cs.amherst.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030611233626.A30212@algol.cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Scott F. H. Kaplan" <sfkaplan@algol.cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2003 at 11:36:26PM -0400, Scott F. H. Kaplan wrote:
> On this point, I disagree.  Given Shansi's goal of ``doing a research
> project'', choosing a stable, documented kernel may be a better idea
> than a developmental kernel.  I may misinterpret the aim of this work,
> but based on the description (comparing a new page replacement
> algorithm against LRU), it seems unlikely that the immediate goal is
> to implement ``major design changes'' that can be aborbed into a
> codebase.  It seems that the intention is simply to use Linux as an
> experimental platform to gather results for page replacment policy
> comparisons.

This was in no small part a reaction to the backportmania and
proliferation of grossly inappropriate patches against the stable
series of the past several years. IMHO, it is a justified one.

If the goals are truly limited to using 2.4.x as a pure research
vehicle, I say there are no holds barred. But experience is the mother
of pessimism, and I'd rather keep it on the pill than see another
litter of 2.4.x-based core subsystem rewrites or "dev trees" hatched.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
