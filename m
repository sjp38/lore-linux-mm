Date: Tue, 21 Oct 2008 10:29:58 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081021162957.GQ26184@parisc-linux.org>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com> <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu> <E1KsK5R-0006mR-AO@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KsK5R-0006mR-AO@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: steve@chygwyn.com, zbr@ioremap.net, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 21, 2008 at 06:28:01PM +0200, Miklos Szeredi wrote:
> On Tue, 21 Oct 2008, Miklos Szeredi wrote:
> > BTW, why do you want strict coherency for memory mappings?  It's not
> > something POSIX mandates.  It's not even something that Linux always
> > did.
> 
> Or does, for that matter, on those architectures which have virtually
> addressed caches.

Careful with those slurs you're throwing around.  PA-RISC carefully
aligns its mmaps so they are coherent.

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
