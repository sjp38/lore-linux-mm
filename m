Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 374D86B005D
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 16:49:17 -0400 (EDT)
Date: Tue, 17 Jul 2012 13:49:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix wrong argument of migrate_huge_pages() in
 soft_offline_huge_page()
Message-Id: <20120717134915.76adf9bd.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1207171340420.9675@chino.kir.corp.google.com>
References: <1342544460-20095-1-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207171340420.9675@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

On Tue, 17 Jul 2012 13:42:23 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 18 Jul 2012, Joonsoo Kim wrote:
> 
> > Commit a6bc32b899223a877f595ef9ddc1e89ead5072b8 ('mm: compaction: introduce
> > sync-light migration for use by compaction') change declaration of
> > migrate_pages() and migrate_huge_pages().
> > But, it miss changing argument of migrate_huge_pages()
> > in soft_offline_huge_page(). In this case, we should call with MIGRATE_SYNC.
> > So change it.
> > 
> > Additionally, there is mismatch between type of argument and function
> > declaration for migrate_pages(). So fix this simple case, too.
> > 
> > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Should be cc'd to stable for 3.3+.

Well, why?  I'm suspecting a switch from MIGRATE_SYNC_LIGHT to
MIGRATE_SYNC will have no discernable effect.  Unless it triggers hitherto
unknkown about deadlocks...

For a -stable backport we should have a description of the end-user
visible effects of the bug.  This changelog lacked such a description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
