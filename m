Date: Sun, 13 Oct 2002 14:22:49 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.42-mm2
Message-ID: <20021013212249.GE27878@holomorphy.com>
References: <3DA7C3A5.98FCC13E@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DA7C3A5.98FCC13E@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 11, 2002 at 11:39:33PM -0700, Andrew Morton wrote:
> url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.42/2.5.42-mm2/

To future-proof NUMA-Q vs. similar issues to pcp->reserved:


--- linux-2.5.42/arch/i386/mm/discontig.c	2002-10-11 21:22:09.000000000 -0700
+++ virgin-2.5.42/arch/i386/mm/discontig.c	2002-10-13 14:18:19.000000000 -0700
@@ -70,6 +70,7 @@ static void __init allocate_pgdat(int ni
 	node_datasz = PFN_UP(sizeof(struct pglist_data));
 	NODE_DATA(nid) = (pg_data_t *)(__va(min_low_pfn << PAGE_SHIFT));
 	min_low_pfn += node_datasz;
+	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
 }
 
 /*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
