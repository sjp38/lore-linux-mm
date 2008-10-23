Date: Thu, 23 Oct 2008 07:48:04 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081023134804.GL26094@parisc-linux.org>
References: <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com> <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu> <E1KsK5R-0006mR-AO@pomaz-ex.szeredi.hu> <20081021162957.GQ26184@parisc-linux.org> <20081022124829.GA826@shareable.org> <20081022134531.GE26094@parisc-linux.org> <E1KseI2-0001G8-3Y@pomaz-ex.szeredi.hu> <20081022143511.GF26094@parisc-linux.org> <E1Ksexg-0001Ng-8F@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1Ksexg-0001Ng-8F@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jamie@shareable.org, steve@chygwyn.com, zbr@ioremap.net, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 22, 2008 at 04:45:24PM +0200, Miklos Szeredi wrote:
> On Wed, 22 Oct 2008, Matthew Wilcox wrote:
> > remap_file_pages() only hurts if you map the same page more than once
> > (which is permitted, but again, I don't think anyone actually does
> > that).
> 
> This is getting very offtopic... but remap_file_pages() is just like
> MAP_FIXED, that the address at which a page is mapped is determined by
> the caller, not the kernel.  So coherency with other, independent
> mapping of the file is basically up to chance.

Oh, right, I see.

> Do we care?  I very much hope not.  Why do PA-RISC and friends care at
> all about mmap coherecy?  Is it real-world problem driven or just to
> be safe?

One reason to care is performance.  If two tasks have libc mapped
coherently, then the addresses will collide in the cache and they'll
use the same cachelines.  I don't know how much applications care about
correctness with mmap -- they certainly do with sysv shm.  I probably
knew about some applications that broke when I was working on this code --
back in 2002.

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
