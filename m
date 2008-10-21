In-reply-to: <20081021145901.GA28279@fogou.chygwyn.com> (steve@chygwyn.com)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com>
Message-Id: <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 21 Oct 2008 18:20:17 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steve@chygwyn.com
Cc: zbr@ioremap.net, miklos@szeredi.hu, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008, steve@chygwyn.co wrote:
> No, I guess it might be possible, but for the time being it is
> its own "glock" plus the page lock dependency. I'd have to
> think quite hard about what the consequences of using the
> inode lock would be.
> 
> Of course we do demand the inode lock as well in some cases
> since the vfs has already grabbed it before calling
> into the filesystem when its required. Because of that and
> where we run the glock state machine from, it would be rather
> complicated to make that work I suspect,

BTW, why do you want strict coherency for memory mappings?  It's not
something POSIX mandates.  It's not even something that Linux always
did.

If I were an application writer, I'd never try to rely on mmap
coherency without the appropriate magic msync() calls.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
