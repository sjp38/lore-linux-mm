Date: Fri, 24 May 2002 12:35:35 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH] using page aging to shrink caches (pre8-ac5)
Message-ID: <20020524123535.A9618@infradead.org>
References: <200205180010.51382.tomlins@cam.org> <20020521144759.B1153@redhat.com> <200205240728.45558.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200205240728.45558.tomlins@cam.org>; from tomlins@cam.org on Fri, May 24, 2002 at 07:28:45AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2002 at 07:28:45AM -0400, Ed Tomlinson wrote:
> Comments, questions and feedback very welcome,

Just from a short look:

What about doing mark_page_accessed in kmem_touch_page?
And please do a s/pruner_t/kmem_pruner_t/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
