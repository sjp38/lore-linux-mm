Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 1938F6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 16:42:27 -0400 (EDT)
Received: by ggm4 with SMTP id 4so1093157ggm.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 13:42:26 -0700 (PDT)
Date: Tue, 17 Jul 2012 13:42:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix wrong argument of migrate_huge_pages() in
 soft_offline_huge_page()
In-Reply-To: <1342544460-20095-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207171340420.9675@chino.kir.corp.google.com>
References: <1342544460-20095-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

On Wed, 18 Jul 2012, Joonsoo Kim wrote:

> Commit a6bc32b899223a877f595ef9ddc1e89ead5072b8 ('mm: compaction: introduce
> sync-light migration for use by compaction') change declaration of
> migrate_pages() and migrate_huge_pages().
> But, it miss changing argument of migrate_huge_pages()
> in soft_offline_huge_page(). In this case, we should call with MIGRATE_SYNC.
> So change it.
> 
> Additionally, there is mismatch between type of argument and function
> declaration for migrate_pages(). So fix this simple case, too.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

Should be cc'd to stable for 3.3+.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
