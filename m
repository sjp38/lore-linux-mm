In-reply-to: <20081022143511.GF26094@parisc-linux.org> (message from Matthew
	Wilcox on Wed, 22 Oct 2008 08:35:11 -0600)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com> <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu> <E1KsK5R-0006mR-AO@pomaz-ex.szeredi.hu> <20081021162957.GQ26184@parisc-linux.org> <20081022124829.GA826@shareable.org> <20081022134531.GE26094@parisc-linux.org> <E1KseI2-0001G8-3Y@pomaz-ex.szeredi.hu> <20081022143511.GF26094@parisc-linux.org>
Message-Id: <E1Ksexg-0001Ng-8F@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 22 Oct 2008 16:45:24 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: matthew@wil.cx
Cc: miklos@szeredi.hu, jamie@shareable.org, steve@chygwyn.com, zbr@ioremap.net, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Matthew Wilcox wrote:
> remap_file_pages() only hurts if you map the same page more than once
> (which is permitted, but again, I don't think anyone actually does
> that).

This is getting very offtopic... but remap_file_pages() is just like
MAP_FIXED, that the address at which a page is mapped is determined by
the caller, not the kernel.  So coherency with other, independent
mapping of the file is basically up to chance.

Do we care?  I very much hope not.  Why do PA-RISC and friends care at
all about mmap coherecy?  Is it real-world problem driven or just to
be safe?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
