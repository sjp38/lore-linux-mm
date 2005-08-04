Date: Thu, 4 Aug 2005 14:04:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <20050804114812.GB31596@lnx-holt.americas.sgi.com>
Message-ID: <Pine.LNX.4.61.0508041352100.3365@goblin.wat.veritas.com>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
 <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
 <Pine.LNX.4.58.0508011116180.3341@g5.osdl.org> <20050803082414.GB6384@lnx-holt.americas.sgi.com>
 <Pine.LNX.4.61.0508031223590.13845@goblin.wat.veritas.com>
 <20050804114812.GB31596@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Aug 2005, Robin Holt wrote:
> On Wed, Aug 03, 2005 at 12:31:34PM +0100, Hugh Dickins wrote:
> > On Wed, 3 Aug 2005, Robin Holt wrote:
> > > On Mon, Aug 01, 2005 at 11:18:42AM -0700, Linus Torvalds wrote:
> > > > 
> > > > Can somebody who saw the problem in the first place please verify?
> 
> OK.  I took the three commits:
> 4ceb5db9757aaeadcf8fbbf97d76bd42aa4df0d6
> f33ea7f404e592e4563b12101b7a4d17da6558d7
> a68d2ebc1581a3aec57bd032651e013fa609f530
> 
> I back ported them to the SuSE SLES9SP2 kernel.  I will add them at
> the end so you can tell me if I messed things up.  I was then able
> to run the customer test application multiple times without issue.
> Before the fix, we had never acheived three consecutive runs that did
> not trip the fault.  After the change, it has been in excess of thirty.
> I would say this has fixed the problem.  Did I miss anything which
> needs to be tested?

Great, thanks for the testing, the set of patches you tested is correct.

(I think there is one minor anomaly in your patch backport, which has no
effect on the validity of your testing: you've probably ended up with two
separate calls to set_page_dirty in your follow_page, because that moved
between 2.6.5 and 2.6.13.  It doesn't matter, but you might want to tidy
that up one way or the other if you're passing your patch on further.)

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
