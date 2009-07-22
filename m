Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9956B0121
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 13:55:27 -0400 (EDT)
Date: Wed, 22 Jul 2009 19:54:17 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/4] mm: document is_page_cache_freeable()
Message-ID: <20090722175417.GA7059@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-4-git-send-email-hannes@cmpxchg.org> <alpine.DEB.1.10.0907221220350.3588@gentwo.org> <20090722175031.GA3484@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090722175031.GA3484@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 22, 2009 at 07:50:31PM +0200, Johannes Weiner wrote:
> On Wed, Jul 22, 2009 at 12:49:44PM -0400, Christoph Lameter wrote:
> > >  static inline int is_page_cache_freeable(struct page *page)
> > >  {
> > > -	return page_count(page) - !!page_has_private(page) == 2;
> > > +	return page_count(page) - page_has_private(page) == 2;
> > 
> > That looks funky and in need of comments.

Enlighten the reader of this code about what reference count makes a
page cache page freeable.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 67e2824..d18f46d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -286,6 +286,11 @@ static inline int page_mapping_inuse(struct page *page)
 
 static inline int is_page_cache_freeable(struct page *page)
 {
+	/*
+	 * A freeable page cache page is referenced only by the caller
+	 * that isolated the page, the page cache itself and
+	 * optionally the page's buffers, if any.
+	 */
 	return page_count(page) - page_has_private(page) == 2;
 }
 
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
