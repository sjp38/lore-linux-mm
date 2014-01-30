Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id E1ADF6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 15:58:03 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so3555624pbc.26
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 12:58:03 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ds4si7812948pbb.319.2014.01.30.12.58.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 12:58:02 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so3608364pab.37
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 12:58:02 -0800 (PST)
Date: Thu, 30 Jan 2014 12:58:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, hugetlb: gimme back my page
In-Reply-To: <52EA57AC.3090700@oracle.com>
Message-ID: <alpine.DEB.2.02.1401301256540.15271@chino.kir.corp.google.com>
References: <1391063823.2931.3.camel@buesod1.americas.hpqcorp.net> <52EA57AC.3090700@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jonathan Gonzalez <jgonzalez@linets.cl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jan 2014, Sasha Levin wrote:

> VM_BUG_ON_PAGE is just a VM_BUG_ON that does dump_page before the BUG().
> 
> The only reason to use VM_BUG_ON instead of VM_BUG_ON_PAGE is if the page
> you're working
> with doesn't make sense/isn't useful as debug output.
> 
> If doing a dump_page is causing issues somewhere then dump_pages should be
> fixed - instead
> of hiding the problem under the rug by not using it.
> 

It sounds like dump_page() isn't necessarily at fault itself but rather 
that using it is opening a race even wider that causes this failure to 
occur more often than it normally would.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
