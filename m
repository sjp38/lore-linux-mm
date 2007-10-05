In-reply-to: <E1IdkOf-0002tK-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Fri, 05 Oct 2007 12:27:05 +0200)
Subject: Re: [PATCH] remove throttle_vm_writeout()
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	 <20071004145640.18ced770.akpm@linux-foundation.org>
	 <E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	 <20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	 <E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
	 <20071004164801.d8478727.akpm@linux-foundation.org>
	 <E1Idanu-0002c1-00@dorka.pomaz.szeredi.hu>
	 <20071004174851.b34a3220.akpm@linux-foundation.org>
	 <1191572520.22357.42.camel@twins>
	 <E1IdjOa-0002qg-00@dorka.pomaz.szeredi.hu> <1191577623.22357.69.camel@twins> <E1IdkOf-0002tK-00@dorka.pomaz.szeredi.hu>
Message-Id: <E1IdkTY-0002tc-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 05 Oct 2007 12:32:08 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I think that's an improvement in all respects.
> 
> However it still does not generally address the deadlock scenario: if
> there's a small DMA zone, and fuse manages to put all of those pages
> under writeout, then there's trouble.

And the only way to solve that AFAICS, is to make sure fuse never uses
more than e.g. 50% of _any_ zone for page cache.  And that may need
some tweaking in the allocator...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
