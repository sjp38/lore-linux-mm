Date: Fri, 10 Oct 2008 19:29:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2/8] mm: write_cache_pages AOP_WRITEPAGE_ACTIVATE fix
In-Reply-To: <E1KoKPp-0000IW-6m@pomaz-ex.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0810101919530.17254@blonde.site>
References: <20081009155039.139856823@suse.de> <20081009174822.298327659@suse.de>
 <E1KoKPp-0000IW-6m@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: npiggin@suse.de, akpm@linux-foundation.org, mpatocka@redhat.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Oct 2008, Miklos Szeredi wrote:
> On Fri, 10 Oct 2008, npiggin@suse.de wrote:
> > In write_cache_pages, if AOP_WRITEPAGE_ACTIVATE is returned, the
> > filesystem is calling on us to drop the page lock and retry,
> 
> Are you sure?  It's not what fs.h says.  I think this return value is
> related to reclaim (and only used by shmfs), and retrying is not the
> right thing in that case.

Only used by shmfs nowadays, yes; it means go away for now,
don't keep on spamming me with this, but try it again later on.

Though I didn't invent it, it's very much my fault that it
still exists: I've had a patch to remove it (setting PageActive
instead, ending that horrid "but in this case, return with the
page still locked") for about a year, but still hadn't got around
to verifying that it really does what's intended, before the more
interesting split-lru changes reached -mm, and I thought it polite
to hold off for now (though in fact there's almost no conflict).
I'll get there...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
