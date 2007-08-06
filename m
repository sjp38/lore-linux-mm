Date: Mon, 6 Aug 2007 12:42:06 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070806104206.GB16133@one.firstfloor.org>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <p73hcnen7w2.fsf@bingen.suse.de> <20070805204112.GC25107@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805204112.GC25107@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

On Sun, Aug 05, 2007 at 09:41:12PM +0100, Christoph Hellwig wrote:
> On Sun, Aug 05, 2007 at 02:26:53AM +0200, Andi Kleen wrote:
> > I always thought the right solution would be to just sync atime only
> > very very lazily. This means if a inode is only dirty because of an
> > atime update put it on a "only write out when there is nothing to do
> > or the memory is really needed" list.
> 
> Which is the policy I implemented for XFS a while ago.

How would that work? I didn't think XFS had separate inode lists.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
