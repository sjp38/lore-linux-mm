Date: Wed, 31 May 2006 19:56:48 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [rfc][patch] remove racy sync_page?
Message-ID: <20060531175648.GZ29535@suse.de>
References: <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au> <447BD9CE.2020505@yahoo.com.au> <Pine.LNX.4.64.0605301911480.10355@blonde.wat.veritas.com> <447CE1A3.60507@yahoo.com.au> <Pine.LNX.4.64.0605310335180.4441@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605310335180.4441@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, May 31 2006, Hugh Dickins wrote:
> > What places want to use set_page_dirty_lock without sleeping?
> > The only place in drivers/ apart from sg/st that SetPageDirty are
> > rd.c and via_dmablit.c, both of which look OK, if a bit crufty.
> 
> I've not looked recently, but bio.c sticks in the mind as one which
> is pushed to the full contortions to allow for sleeping there.

Indeed, there's a whole bunch of functions and punting to workqueues
just to work around that :-)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
