From: Chris Mason <mason@suse.com>
Subject: Re: "orphaned pagecache memleak fix" question.
Date: Wed, 6 Apr 2005 17:12:46 -0400
References: <16978.46735.644387.570159@gargle.gargle.HOWL> <20050406005804.0045faf9.akpm@osdl.org>
In-Reply-To: <20050406005804.0045faf9.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200504061712.47244.mason@suse.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <nikita@clusterfs.com>, Andrea@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 06 April 2005 03:58, Andrew Morton wrote:

> >  - wouldn't it be simpler to unconditionally remove page from LRU in
> >  ->invalidatepage()?
>
> I guess that's an option, yes.  If the fs cannot successfully invalidate
> the page then it can either block (as described above) or remove the page
> from the LRU.  The fs then wholly owns the page.
>
> I think it would be better to make ->invalidatepage always succeed though.
> The situation is probably rare.

In data=journal it isn't rare at all.  Dropping the page from the lru would be 
the best solution I think.

-chris
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
