Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id EF9D16B005C
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:23:18 -0400 (EDT)
Date: Mon, 16 Jul 2012 12:23:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: correct return value of migrate_pages()
In-Reply-To: <1342455272-32703-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207161220440.32319@router.home>
References: <Yes> <1342455272-32703-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 17 Jul 2012, Joonsoo Kim wrote:

> migrate_pages() should return number of pages not migrated or error code.
> When unmap_and_move return -EAGAIN, outer loop is re-execution without
> initialising nr_failed. This makes nr_failed over-counted.

The itention of the nr_failed was only to give an indication as to how
many attempts where made. The failed pages where on a separate queue that
seems to have vanished.

> So this patch correct it by initialising nr_failed in outer loop.

Well yea it makes sense since retry is initialized there as well.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
