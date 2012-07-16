Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C1C876B0069
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:29:38 -0400 (EDT)
Date: Mon, 16 Jul 2012 12:29:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: fix return value in
 __alloc_contig_migrate_range()
In-Reply-To: <1342455272-32703-3-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207161229200.32319@router.home>
References: <Yes> <1342455272-32703-1-git-send-email-js1304@gmail.com> <1342455272-32703-3-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>

On Tue, 17 Jul 2012, Joonsoo Kim wrote:

> migrate_pages() would return positive value in some failure case,
> so 'ret > 0 ? 0 : ret' may be wrong.
> This fix it and remove one dead statement.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
