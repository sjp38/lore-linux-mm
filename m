Date: Wed, 11 Jun 2003 09:50:17 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: How to fix the total size of buffer caches in 2.4.5?
Message-ID: <20030611165017.GS15692@holomorphy.com>
References: <20030611162224.GR15692@holomorphy.com> <Pine.LNX.4.44.0306111226160.1656-100000@ickis.cs.wm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0306111226160.1656-100000@ickis.cs.wm.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shansi Ren <sren@CS.WM.EDU>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2003 at 12:28:18PM -0400, Shansi Ren wrote:
> What version do you suggest then? The reason why I choose 2.4.5 is that 
> I'm doing a research project. Experiments on earlier versions may not be 
> persuasive to audience.

That's actually too old, not too new.

You do realize that the 3rd number in the point releases is a
patchlevel, and does not indicate major kernel-wide changes? i.e. if
you're going to hack on 2.4.x, the highest value of x indicates the
version with the most bugfixes. 2.4.y vs. 2.4.x with y > x does not
indicate a brand new major kernel version with oodles of new features,
major subsystems redesigned, and so on.

Also, 2.4.x is relatively deeply frozen. I won't consult Marcelo (he
has enough to deal with), but IMHO it's not productive to demonstrate
major design changes against a codebase that can (by definition) never
absorb them. i.e. it'd be best to try to work against current 2.5.x.

I myself am brewing up something that appears to be suffering from bad
timing wrt. the release cycle. The way I'm going to handle that is just
keeping it current until the next development cycle opens. This is not
painless (in fact, it is "very painful").


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
