Date: Fri, 3 Aug 2007 15:21:03 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
In-Reply-To: <20070803123712.987126000@chello.nl>
Message-ID: <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
References: <20070803123712.987126000@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>


On Fri, 3 Aug 2007, Peter Zijlstra wrote:
> 
> These patches aim to improve balance_dirty_pages() and directly address three
> issues:
>   1) inter device starvation
>   2) stacked device deadlocks
>   3) inter process starvation

Ok, the patches certainly look pretty enough, and you fixed the only thing 
I complained about last time (naming), so as far as I'm concerned it's now 
just a matter of whether it *works* or not. I guess being in -mm will help 
somewhat, but it would be good to have people with several disks etc 
actively test this out.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
