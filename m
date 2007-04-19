Subject: Re: [PATCH 09/12] mm: count unstable pages per BDI
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HecBc-0006vS-00@dorka.pomaz.szeredi.hu>
References: <20070417071046.318415445@chello.nl>
	 <20070417071703.710381113@chello.nl>
	 <E1Heafy-0006ia-00@dorka.pomaz.szeredi.hu> <1177006362.2934.13.camel@lappy>
	 <1177008406.2934.19.camel@lappy> <E1HecBc-0006vS-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Thu, 19 Apr 2007 21:23:32 +0200
Message-Id: <1177010612.7066.20.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-19 at 21:20 +0200, Miklos Szeredi wrote:
> > Index: linux-2.6/fs/buffer.c
> > ===================================================================
> > --- linux-2.6.orig/fs/buffer.c	2007-04-19 19:59:26.000000000 +0200
> > +++ linux-2.6/fs/buffer.c	2007-04-19 20:35:39.000000000 +0200
> > @@ -733,7 +733,7 @@ int __set_page_dirty_buffers(struct page
> >  	if (page->mapping) {	/* Race with truncate? */
> >  		if (mapping_cap_account_dirty(mapping)) {
> >  			__inc_zone_page_state(page, NR_FILE_DIRTY);
> > -			__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> > +			__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIM);
> 
> This name suggests it's _under_ reclaim, which is not true.  You might
> rather want to call it BDI_RECLAIMABLE, or something similar in
> meaning.

Yeah, my fingers got lazy on me :-) will instruct them to type more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
