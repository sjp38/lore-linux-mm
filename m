Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [RFC][PATCH] using page aging to shrink caches (pre8-ac5)
Date: Fri, 24 May 2002 08:14:25 -0400
References: <200205180010.51382.tomlins@cam.org> <200205240728.45558.tomlins@cam.org> <20020524123535.A9618@infradead.org>
In-Reply-To: <20020524123535.A9618@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200205240814.25293.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 24, 2002 07:35 am, Christoph Hellwig wrote:
> On Fri, May 24, 2002 at 07:28:45AM -0400, Ed Tomlinson wrote:
> > Comments, questions and feedback very welcome,
>
> Just from a short look:
>
> What about doing mark_page_accessed in kmem_touch_page?

mark_page_accessed expects a page struct.  kmem_touch_page takes an
address in the page, converts it to a kernel address and then marks the page.

> And please do a s/pruner_t/kmem_pruner_t/

Yes.  Done.

One other style question.  I am not completely happy with kmem_shrink_slab.
Think that instead of setting the reference bit I should probably do something
like return:

-1	- cache is growing
  0	- slab has inuse objects
  n    - pages were freed

Comments?
Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
