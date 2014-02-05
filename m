Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 09A1C6B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 19:32:21 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id g12so10845119oah.3
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:32:20 -0800 (PST)
Received: from g4t0014.houston.hp.com (g4t0014.houston.hp.com. [15.201.24.17])
        by mx.google.com with ESMTPS id pp9si13005777obc.89.2014.02.04.16.32.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 16:32:20 -0800 (PST)
Message-ID: <1391560337.2501.0.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [patch] mm, hugetlb: mark some bootstrap functions as __init
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 04 Feb 2014 16:32:17 -0800
In-Reply-To: <alpine.DEB.2.02.1402041612120.14962@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1402041612120.14962@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2014-02-04 at 16:13 -0800, David Rientjes wrote:
> Both prep_compound_huge_page() and prep_compound_gigantic_page() are only
> called at bootstrap and can be marked as __init.
> 
> The __SetPageTail(page) in prep_compound_gigantic_page() happening before
> page->first_page is initialized is not concerning since this is
> bootstrap.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
