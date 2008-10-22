Date: Wed, 22 Oct 2008 08:35:11 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081022143511.GF26094@parisc-linux.org>
References: <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com> <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu> <E1KsK5R-0006mR-AO@pomaz-ex.szeredi.hu> <20081021162957.GQ26184@parisc-linux.org> <20081022124829.GA826@shareable.org> <20081022134531.GE26094@parisc-linux.org> <E1KseI2-0001G8-3Y@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KseI2-0001G8-3Y@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jamie@shareable.org, steve@chygwyn.com, zbr@ioremap.net, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 22, 2008 at 04:02:22PM +0200, Miklos Szeredi wrote:
> On Wed, 22 Oct 2008, Matthew Wilcox wrote:
> > On Wed, Oct 22, 2008 at 01:48:29PM +0100, Jamie Lokier wrote:
> > > Matthew Wilcox wrote:
> > > > Careful with those slurs you're throwing around.  PA-RISC carefully
> > > > aligns its mmaps so they are coherent.
> > > 
> > > (Unless you use MAP_FIXED?)
> > 
> > Doctor, it hurts when I point this gun at my foot and pull the trigger
> > ...
> 
> And remap_file_pages() also.  Neither that nor MAP_FIXED are widely
> used, but still, coherency is not a completely solved issue.

remap_file_pages() only hurts if you map the same page more than once
(which is permitted, but again, I don't think anyone actually does
that).

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
