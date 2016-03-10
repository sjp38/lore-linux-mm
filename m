Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9300B6B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 14:35:38 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 129so76065848pfw.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:35:38 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a5si7932767pat.63.2016.03.10.11.35.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 11:35:37 -0800 (PST)
Date: Thu, 10 Mar 2016 22:35:22 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: mm: keep page cache radix tree nodes in check
Message-ID: <20160310193522.GC5273@mwanda>
References: <20160310125922.GA15269@mwanda>
 <20160310161200.GA11651@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160310161200.GA11651@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org

On Thu, Mar 10, 2016 at 11:12:00AM -0500, Johannes Weiner wrote:
> We know that page->tree[page->index] is present and the tree is
> locked, so __radix_tree_lookup() will always return with an entry, as
> well as &node and &slot set. I'm not sure how you would annotate this.
> 

That's tricky...

> Is it also warning about slot?

It does, yes.

> Or can it know that they are always set
> together?

It knows they are set together but it warns about both.

> Could it maybe be linked to the function's return value? I
> would prefer not setting node and slot to NULL to suppress the false
> positive. However, what we could do is add a BUG_ON() if the function
> call returns NULL. Would that be enough of a hint to the checker that
> we expect the function to be always successful and set node and slot?

I'm sort of just trying to get a feel for what the issues are.  Calling
BUG_ON() would silence the warning, yes.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
