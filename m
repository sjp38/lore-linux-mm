Date: Tue, 21 Oct 2008 17:25:01 +0100
From: steve@chygwyn.com
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081021162501.GA29653@fogou.chygwyn.com>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com> <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: zbr@ioremap.net, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Oct 21, 2008 at 06:20:17PM +0200, Miklos Szeredi wrote:
> On Tue, 21 Oct 2008, steve@chygwyn.co wrote:
> > No, I guess it might be possible, but for the time being it is
> > its own "glock" plus the page lock dependency. I'd have to
> > think quite hard about what the consequences of using the
> > inode lock would be.
> > 
> > Of course we do demand the inode lock as well in some cases
> > since the vfs has already grabbed it before calling
> > into the filesystem when its required. Because of that and
> > where we run the glock state machine from, it would be rather
> > complicated to make that work I suspect,
> 
> BTW, why do you want strict coherency for memory mappings?  It's not
> something POSIX mandates.  It's not even something that Linux always
> did.
>
Its something that GFS has always done, and so we've tried to keep
that feature in GFS2. I think we do (at least I do) try to suggest
to people that they shouldn't be relying on this, but we've always
tried to make it work anyway, at least on the principle of least
surprise.
 
> If I were an application writer, I'd never try to rely on mmap
> coherency without the appropriate magic msync() calls.
> 
> Miklos

Yes, I'd agree, but I write kernel code, not applications :-)
Thanks for the explanation on splice, I'll take a look at that
code now and try to understand it in more detail,

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
