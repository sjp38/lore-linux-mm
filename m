Date: Wed, 22 Oct 2008 07:45:31 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081022134531.GE26094@parisc-linux.org>
References: <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com> <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu> <E1KsK5R-0006mR-AO@pomaz-ex.szeredi.hu> <20081021162957.GQ26184@parisc-linux.org> <20081022124829.GA826@shareable.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081022124829.GA826@shareable.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, steve@chygwyn.com, zbr@ioremap.net, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 22, 2008 at 01:48:29PM +0100, Jamie Lokier wrote:
> Matthew Wilcox wrote:
> > Careful with those slurs you're throwing around.  PA-RISC carefully
> > aligns its mmaps so they are coherent.
> 
> (Unless you use MAP_FIXED?)

Doctor, it hurts when I point this gun at my foot and pull the trigger
...

> Last time I looked at the coherency code, there appeared to be a few
> bugs on some architectures, but I didn't have the architectures to
> test and confirm them.  It was a long time ago, in the 2.4 era though.

I think there's a few parisc machines floating around looking for good
homes if you're interested.

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
