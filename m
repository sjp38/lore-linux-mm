Date: Thu, 11 May 2000 14:47:25 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: PATCH: rewrite of invalidate_inode_pages
In-Reply-To: <ytt4s84ix4z.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On 11 May 2000, Juan J. Quintela wrote:
> - we change one page_cache_release to put_page in truncate_inode_pages
>   (people find lost when they see a get_page without the correspondent
>   put_page, and put_page and page_cache_release are synonimops)

put_page() is _not_ synonymous with page_cache_release()!

Imagine a time in the not too distant future when the page cache
granularity is 8kB or 16kB due to better IO performance (possibly
controlled by a config option), and page_cache_release() will do an
"order=1" or "order=2" page free..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
