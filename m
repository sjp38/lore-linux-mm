Date: Tue, 15 Jul 2008 08:22:50 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: xfs bug in 2.6.26-rc9
Message-ID: <20080715122250.GA15744@infradead.org>
References: <alpine.DEB.1.10.0807110939520.30192@uplift.swm.pp.se> <487B019B.9090401@sgi.com> <20080714121332.GX29319@disturbed> <200807151617.58329.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200807151617.58329.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Dave Chinner <david@fromorbit.com>, Lachlan McIlroy <lachlan@sgi.com>, Mikael Abrahamsson <swmike@swm.pp.se>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It would be easily possible to do, yes.

What happened to your plans to merge ->nopfn into ->fault?  Beeing
able to restart page based faults would be a logical fallout from that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
