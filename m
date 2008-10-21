Date: Tue, 21 Oct 2008 15:59:01 +0100
From: steve@chygwyn.com
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081021145901.GA28279@fogou.chygwyn.com>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081021143518.GA7158@2ka.mipt.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Cc: Miklos Szeredi <miklos@szeredi.hu>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Oct 21, 2008 at 06:35:18PM +0400, Evgeniy Polyakov wrote:
> Hi.
> 
> On Tue, Oct 21, 2008 at 02:38:14PM +0100, steve@chygwyn.com (steve@chygwyn.com) wrote:
> > As a result of that, the VFS needs reads (and page_mkwrite) to
> > retry when !PageUptodate() in case the returned page has been
> > invalidated at any time when the page lock has been dropped.
> 
> Doesn't it happen under appropriate inode lock being held,
> which is a main serialization point?
> 
> -- 
> 	Evgeniy Polyakov

No, I guess it might be possible, but for the time being it is
its own "glock" plus the page lock dependency. I'd have to
think quite hard about what the consequences of using the
inode lock would be.

Of course we do demand the inode lock as well in some cases
since the vfs has already grabbed it before calling
into the filesystem when its required. Because of that and
where we run the glock state machine from, it would be rather
complicated to make that work I suspect,

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
