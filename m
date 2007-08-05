Date: Sun, 5 Aug 2007 21:43:05 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805204305.GD25107@infradead.org>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804094119.81d8e533.akpm@linux-foundation.org> <87wswbjejw.fsf@mid.deneb.enyo.de> <20070804230007.30857453.akpm@linux-foundation.org> <87r6miza5t.fsf@mid.deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r6miza5t.fsf@mid.deneb.enyo.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

On Sun, Aug 05, 2007 at 09:57:02AM +0200, Florian Weimer wrote:
> For instance, some editors don't perform fsync-then-rename, but simply
> truncate the file when saving (because they want to preserve hard
> links).  With XFS, this tends to cause null bytes on crashes.  Since
> ext3 has got a much larger install base, this would result in lots of
> bug reports, I fear.

XFS has recently been changed to only updated the on-disk i_size after
data writeback has finished to get rid of this irritation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
