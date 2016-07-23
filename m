Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4ECC76B0253
	for <linux-mm@kvack.org>; Sat, 23 Jul 2016 16:59:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so310086058pfg.3
        for <linux-mm@kvack.org>; Sat, 23 Jul 2016 13:59:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id xz3si24141649pab.244.2016.07.23.13.59.14
        for <linux-mm@kvack.org>;
        Sat, 23 Jul 2016 13:59:14 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/2] mm: optimize copy_page_to/from_iter_iovec
References: <alpine.LRH.2.02.1607221656530.4818@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.LRH.2.02.1607221711410.4818@file01.intranet.prod.int.rdu2.redhat.com>
Date: Sat, 23 Jul 2016 13:59:13 -0700
In-Reply-To: <alpine.LRH.2.02.1607221711410.4818@file01.intranet.prod.int.rdu2.redhat.com>
	(Mikulas Patocka's message of "Fri, 22 Jul 2016 17:12:46 -0400 (EDT)")
Message-ID: <87bn1onk9q.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Mikulas Patocka <mpatocka@redhat.com> writes:
>  	copy = min(bytes, iov->iov_len - skip);
>  
> +#ifdef CONFIG_HIGHMEM
>  	if (!fault_in_pages_writeable(buf, copy)) {

If you use IS_ENABLED in the if here ...

>  	kunmap(page);
> +
> +#ifdef CONFIG_HIGHMEM
>  done:
> +#endif

... you don't need this ifdef.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
