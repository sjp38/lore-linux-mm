Received: (from sfkaplan@localhost)
	by algol.cs.amherst.edu (8.11.6/8.11.6) id h5C3aQc30232
	for linux-mm@kvack.org; Wed, 11 Jun 2003 23:36:26 -0400
Date: Wed, 11 Jun 2003 23:36:26 -0400
From: "Scott F. H. Kaplan" <sfkaplan@algol.cs.amherst.edu>
Subject: Re: How to fix the total size of buffer caches in 2.4.5?
Message-ID: <20030611233626.A30212@algol.cs.amherst.edu>
References: <20030611162224.GR15692@holomorphy.com> <Pine.LNX.4.44.0306111226160.1656-100000@ickis.cs.wm.edu> <20030611165017.GS15692@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030611165017.GS15692@holomorphy.com>; from wli@holomorphy.com on Wed, Jun 11, 2003 at 09:50:17AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2003 at 09:50:17AM -0700, William Lee Irwin III wrote:
> On Wed, Jun 11, 2003 at 12:28:18PM -0400, Shansi Ren wrote:
> > What version do you suggest then? The reason why I choose 2.4.5 is that 
> > I'm doing a research project. Experiments on earlier versions may not be 
> > persuasive to audience.
> 
> That's actually too old, not too new.

On this point, I definitely agree.

> Also, 2.4.x is relatively deeply frozen. I won't consult Marcelo (he
> has enough to deal with), but IMHO it's not productive to demonstrate
> major design changes against a codebase that can (by definition) never
> absorb them. i.e. it'd be best to try to work against current 2.5.x.

On this point, I disagree.  Given Shansi's goal of ``doing a research
project'', choosing a stable, documented kernel may be a better idea
than a developmental kernel.  I may misinterpret the aim of this work,
but based on the description (comparing a new page replacement
algorithm against LRU), it seems unlikely that the immediate goal is
to implement ``major design changes'' that can be aborbed into a
codebase.  It seems that the intention is simply to use Linux as an
experimental platform to gather results for page replacment policy
comparisons.

If I am understanding your situation correctly, Shansi, please let me
know.  For my projects, I've done some of the groundwork of
implementing a more ``classical'' global LRU approximation.  It may
provide you a simpler framework for implementing your own page
replacement policy.  Since my goal is to obtain experimental results
for a research project, and not necessarily to produce code that would
be adopted into the kernel, it may be appropriate for your purposes.
My work is based on the 2.4.20 kernel, which is close to (and may
still be) the latest 2.4.x kernel.

If I am completely off the mark, then forgive me!

Scott
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
