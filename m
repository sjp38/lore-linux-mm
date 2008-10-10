In-reply-to: <20081009174822.298327659@suse.de> (npiggin@suse.de)
Subject: Re: [patch 2/8] mm: write_cache_pages AOP_WRITEPAGE_ACTIVATE fix
References: <20081009155039.139856823@suse.de> <20081009174822.298327659@suse.de>
Message-Id: <E1KoKPp-0000IW-6m@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 10 Oct 2008 18:00:33 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, mpatocka@redhat.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Oct 2008, npiggin@suse.de wrote:
> In write_cache_pages, if AOP_WRITEPAGE_ACTIVATE is returned, the
> filesystem is calling on us to drop the page lock and retry,

Are you sure?  It's not what fs.h says.  I think this return value is
related to reclaim (and only used by shmfs), and retrying is not the
right thing in that case.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
