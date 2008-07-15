From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: xfs bug in 2.6.26-rc9
Date: Tue, 15 Jul 2008 16:17:58 +1000
References: <alpine.DEB.1.10.0807110939520.30192@uplift.swm.pp.se> <487B019B.9090401@sgi.com> <20080714121332.GX29319@disturbed>
In-Reply-To: <20080714121332.GX29319@disturbed>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807151617.58329.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Lachlan McIlroy <lachlan@sgi.com>, Mikael Abrahamsson <swmike@swm.pp.se>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 14 July 2008 22:13, Dave Chinner wrote:

> Christoph and I were contemplating this problem with ->page_mkwrite
> reecently. The problem is that we can't, right now, return an
> EAGAIN-like error to ->page_mkwrite() and have it retry the
> page fault. Other parts of the page faulting code can do this,
> so it seems like a solvable problem.
>
> The basic concept is that if we can return a EAGAIN result we can
> try-lock the inode and hold the locks necessary to avoid this race
> or prevent the page fault from dirtying the page until the
> filesystem is unfrozen.
>
> Added linux-mm to the cc list for discussion.

It would be easily possible to do, yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
