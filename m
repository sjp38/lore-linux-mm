Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3F506B025E
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:40:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so30811206wme.4
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 08:40:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i189si23406553wmi.6.2016.11.14.08.40.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 08:40:57 -0800 (PST)
Date: Mon, 14 Nov 2016 11:39:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] filemap: add comment for confusing logic in
 page_cache_tree_insert()
Message-ID: <20161114163947.GA5141@cmpxchg.org>
References: <20161110163640.126124-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161110163640.126124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Thu, Nov 10, 2016 at 07:36:40PM +0300, Kirill A. Shutemov wrote:
> Unlike THP, hugetlb pages represented by one entry on radix-tree.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Jan Kara <jack@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
