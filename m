Date: Tue, 18 Mar 2008 01:18:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/8] mm: allow not updating BDI stats in
 end_page_writeback()
Message-Id: <20080318011811.252c7c59.akpm@linux-foundation.org>
In-Reply-To: <E1JbWvF-0005Hr-Ur@pomaz-ex.szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
	<20080317191945.122011759@szeredi.hu>
	<20080317220431.a8507e29.akpm@linux-foundation.org>
	<E1JbWvF-0005Hr-Ur@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 09:11:49 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > 
> > Reason: bdi_cap_writeback_dirty() is kinda weirdly intrepreted to mean
> > various different things in different places and we really should separate
> > its multiple interpretations into separate flags.
> > 
> > Note that this becomes a standalone VFS cleanup patch, and the fuse code
> > can then just use it later on.  
> 
> Hmm, I can see two slightly different meanings of bdi_cap_writeback_dirty():
> 
>  1) need to call ->writepage (sync_page_range(), ...)
>  2) need to update BDI stats  (test_clear_page_writeback(), ...)
> 
> If these two were different flags, then fuse could set the
> NEED_WRITEPAGE flag, but clear the NEED_UPDATE_BDI_STATS flag, and do
> it manually.
> 
> Does that sound workable?

Yup, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
