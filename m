Date: Mon, 14 Apr 2003 22:35:37 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.67-mm3
Message-Id: <20030414223537.45808bd9.akpm@digeo.com>
In-Reply-To: <20030415051534.GE706@holomorphy.com>
References: <20030414015313.4f6333ad.akpm@digeo.com>
	<20030415020057.GC706@holomorphy.com>
	<20030415041759.GA12487@holomorphy.com>
	<20030414213114.37dc7879.akpm@digeo.com>
	<20030415043947.GD706@holomorphy.com>
	<20030414215541.0aff47bc.akpm@digeo.com>
	<20030415051534.GE706@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
> On Mon, Apr 14, 2003 at 09:55:41PM -0700, Andrew Morton wrote:
> > Sort-of.  The code is doing two things.
> > a) Make sure that all the relevant pte's are established in the correct
> >    state so we don't take a fault while holding the subsequent atomic kmap.
> >    This is just an optimisation.  If we _do_ take the fault while holding
> >    an atomic kmap, we fall back to sleeping kmap, and do the whole copy
> >    again.  It almost never happens.
> 
> This is the easy part; we're basically just prefaulting.

btw, this may sound like a lot of futzing about, but the other day I
timed four concurrent instances of

	dd if=/dev/zero of=$i bs=1 count=1M

on the four-way.  2.5 ran eight times faster than 2.4.  2.4's kmap_lock
contention was astonishing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
