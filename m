In-reply-to: <1205840031.8514.346.camel@twins> (message from Peter Zijlstra on
	Tue, 18 Mar 2008 12:33:51 +0100)
Subject: Re: [patch 4/8] mm: allow not updating BDI stats in
	end_page_writeback()
References: <20080317191908.123631326@szeredi.hu>
	 <20080317191945.122011759@szeredi.hu> <1205840031.8514.346.camel@twins>
Message-Id: <E1JbaTH-0005jN-4r@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 18 Mar 2008 12:59:11 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: peterz@infradead.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 2008-03-17 at 20:19 +0100, Miklos Szeredi wrote:
> > plain text document attachment (end_page_writeback_nobdi.patch)
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > Fuse's writepage will need to clear page writeback separately from
> > updating the per BDI counters.
> 
> This is because of the juggling with temporary pages, right?
> 
> Would be nice to have some comments in the code explaining this.

Yup, well it will go through a bigger cleanup, as discussed with
Andrew, if that's OK with you?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
