In-reply-to: <20070417071703.710381113@chello.nl> (message from Peter Zijlstra
	on Tue, 17 Apr 2007 09:10:55 +0200)
Subject: Re: [PATCH 09/12] mm: count unstable pages per BDI
References: <20070417071046.318415445@chello.nl> <20070417071703.710381113@chello.nl>
Message-Id: <E1Heafy-0006ia-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 19 Apr 2007 19:44:10 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

> Count per BDI unstable pages.
> 

I'm wondering, is it really worth having this category separate from
per BDI brity pages?

With the exception of the export to sysfs, always the sum of unstable
+ dirty is used.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
