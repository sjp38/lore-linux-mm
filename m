Date: Tue, 21 Oct 2008 18:35:18 +0400
From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081021143518.GA7158@2ka.mipt.ru>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081021133814.GA26942@fogou.chygwyn.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steve@chygwyn.com
Cc: Miklos Szeredi <miklos@szeredi.hu>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi.

On Tue, Oct 21, 2008 at 02:38:14PM +0100, steve@chygwyn.com (steve@chygwyn.com) wrote:
> As a result of that, the VFS needs reads (and page_mkwrite) to
> retry when !PageUptodate() in case the returned page has been
> invalidated at any time when the page lock has been dropped.

Doesn't it happen under appropriate inode lock being held,
which is a main serialization point?

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
