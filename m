Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
From: Andi Kleen <andi@firstfloor.org>
Date: 05 Aug 2007 02:28:19 +0200
In-Reply-To: <20070804103347.GA1956@elte.hu>
Message-ID: <p73d4y2n7to.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> writes:

> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > [ my personal interest in this is the following regression: every time 
> >   i start a large kernel build with DEBUG_INFO on a quad-core 4GB RAM 
> >   box, i get up to 30 seconds complete pauses in Vim (and most other 
> >   tasks), during plain editing of the source code. (which happens when 
> >   Vim tries to write() to its swap/undo-file.) ]
> 
> hm, it turns out that it's due to vim doing an occasional fsync not only 
> on writeout, but during normal use too. "set nofsync" in the .vimrc 
> solves this problem.

It should probably be doing fdatasync() instead. Then ext3 could just
write the data blocks only, but only mess with the logs when the file 
size changed and mtime would be written out somewhat later.

[unless you have data logging enabled]

Does the problem go away when you change it to that? 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
