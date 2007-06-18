Date: Mon, 18 Jun 2007 09:48:58 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] mm: More __meminit annotations.
Message-ID: <20070618074858.GB21222@uranus.ravnborg.org>
References: <20070618143943.B108.Y-GOTO@jp.fujitsu.com> <20070618055842.GA17858@linux-sh.org> <20070618151544.B10A.Y-GOTO@jp.fujitsu.com> <a781481a0706172357s7c473686pa41df174af01cda4@mail.gmail.com> <a781481a0706180028k5d44f27eld7c2d2564c42ed63@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a781481a0706180028k5d44f27eld7c2d2564c42ed63@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Satyam Sharma <satyam.sharma@gmail.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 18, 2007 at 12:58:34PM +0530, Satyam Sharma wrote:
> 
> Actually, modpost will _not_ complain precisely _because_ kernel
> uses always_inline so a separate body for the function will never be
> emitted at all.
That has been threaten to change many times. Far far far too much
are marked inline today. There has been several longer threads about it.

Part of it is that some part MUST be inlined to work while other parts
may be inline but not needed (and often the wrong thing).

So a carefully added inline is good but the other 98% of inline
markings are just wrong and ougth to go.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
