Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6146B0007
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 03:18:20 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p4so521912wmc.8
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 00:18:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3sor3883108edb.47.2018.03.02.00.18.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 00:18:18 -0800 (PST)
Date: Fri, 2 Mar 2018 11:18:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 2/4] mm: Split page_type out from _map_count
Message-ID: <20180302081806.aokjrb27hxqki7at@node.shutemov.name>
References: <20180301211523.21104-1-willy@infradead.org>
 <20180301211523.21104-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180301211523.21104-3-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, linux-api@vger.kernel.org

On Thu, Mar 01, 2018 at 01:15:21PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> We're already using a union of many fields here, so stop abusing the
> _map_count and make page_type its own field.  That implies renaming some

s/_map_count/_mapcount/

and in subject.

> of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
> bring back the PG_buddy, PG_balloon and PG_kmemcg names.
> 
> As suggested by Kirill, make page_type a bitmask.  Because it starts out
> life as -1 (thanks to sharing the storage with _map_count), setting a
> page flag means clearing the appropriate bit.  This gives us space for
> probably twenty or so extra bits (depending how paranoid we want to be
> about _mapcount underflow).
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
