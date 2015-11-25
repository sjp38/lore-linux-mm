Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id EA0C66B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:56:23 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so34320364obd.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 00:56:23 -0800 (PST)
Received: from cmccmta2.chinamobile.com (cmccmta2.chinamobile.com. [221.176.66.80])
        by mx.google.com with ESMTP id v84si14544351oig.58.2015.11.25.00.56.21
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 00:56:23 -0800 (PST)
Date: Wed, 25 Nov 2015 16:55:03 +0800
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: Re: [PATCH] mm/compaction: improve comment
Message-ID: <20151125085503.GA3170@yaowei-K42JY>
References: <1448353427-4240-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <565487B1.9090906@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565487B1.9090906@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mina86@mina86.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 24, 2015 at 04:52:17PM +0100, Vlastimil Babka wrote:
> On 11/24/2015 09:23 AM, Yaowei Bai wrote:
> >Make comment more accurate.
> 
> Make changelog more descriptive? :)

ok

> 
> >Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> >---
> >  mm/compaction.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index de3e1e7..b3cf915 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -1708,7 +1708,9 @@ static void compact_nodes(void)
> >  /* The written value is actually unused, all memory is compacted */
> >  int sysctl_compact_memory;
> >
> >-/* This is the entry point for compacting all nodes via /proc/sys/vm */
> >+/* This is the entry point for compacting all nodes via
> >+ * /proc/sys/vm/compact_memory
> >+ */
> 
> Strictly speaking, multi-line comments should have a leading empty
> line, e.g.:
> 
> /*
>  * This is the entry point ...

Got it, will send an updated one soon. Thanks.

> 
> 
> 
> >  int sysctl_compaction_handler(struct ctl_table *table, int write,
> >  			void __user *buffer, size_t *length, loff_t *ppos)
> >  {
> >
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
