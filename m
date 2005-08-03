Date: Wed, 3 Aug 2005 03:24:14 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
Message-ID: <20050803082414.GB6384@lnx-holt.americas.sgi.com>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com> <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org> <Pine.LNX.4.58.0508011116180.3341@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0508011116180.3341@g5.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 01, 2005 at 11:18:42AM -0700, Linus Torvalds wrote:
> On Mon, 1 Aug 2005, Linus Torvalds wrote:
> > 
> > Ie something like the below (which is totally untested, obviously, but I 
> > think conceptually is a lot more correct, and obviously a lot simpler).
> 
> I've tested it, and thought more about it, and I can't see any fault with
> the approach. In fact, I like it more. So it's checked in now (in a
> further simplified way, since the thing made "lookup_write" always be the
> same as just "write").
> 
> Can somebody who saw the problem in the first place please verify?

Unfortunately, I can not get the user test to run against anything but the
SLES9 SP2 kernel.  I took the commit 4ceb5db9757aaeadcf8fbbf97d76bd42aa4df0d6
and applied that diff to the SUSE kernel.  It does fix the problem the
customer reported.

Thanks,
Robin Holt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
