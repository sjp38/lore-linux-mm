In-reply-to: <20081022134531.GE26094@parisc-linux.org> (message from Matthew
	Wilcox on Wed, 22 Oct 2008 07:45:31 -0600)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com> <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu> <E1KsK5R-0006mR-AO@pomaz-ex.szeredi.hu> <20081021162957.GQ26184@parisc-linux.org> <20081022124829.GA826@shareable.org> <20081022134531.GE26094@parisc-linux.org>
Message-Id: <E1KseI2-0001G8-3Y@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 22 Oct 2008 16:02:22 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: matthew@wil.cx
Cc: jamie@shareable.org, miklos@szeredi.hu, steve@chygwyn.com, zbr@ioremap.net, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Matthew Wilcox wrote:
> On Wed, Oct 22, 2008 at 01:48:29PM +0100, Jamie Lokier wrote:
> > Matthew Wilcox wrote:
> > > Careful with those slurs you're throwing around.  PA-RISC carefully
> > > aligns its mmaps so they are coherent.
> > 
> > (Unless you use MAP_FIXED?)
> 
> Doctor, it hurts when I point this gun at my foot and pull the trigger
> ...

And remap_file_pages() also.  Neither that nor MAP_FIXED are widely
used, but still, coherency is not a completely solved issue.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
