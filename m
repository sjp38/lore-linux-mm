Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id 412706B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 12:50:49 -0500 (EST)
Received: by mail-oa0-f54.google.com with SMTP id i4so5647162oah.27
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 09:50:49 -0800 (PST)
Received: from g1t0026.austin.hp.com (g1t0026.austin.hp.com. [15.216.28.33])
        by mx.google.com with ESMTPS id iz10si5214970obb.117.2014.01.31.09.50.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 09:50:48 -0800 (PST)
Message-ID: <1391190643.3475.7.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm, hugetlb: gimme back my page
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 31 Jan 2014 09:50:43 -0800
In-Reply-To: <alpine.DEB.2.02.1401301256540.15271@chino.kir.corp.google.com>
References: <1391063823.2931.3.camel@buesod1.americas.hpqcorp.net>
	 <52EA57AC.3090700@oracle.com>
	 <alpine.DEB.2.02.1401301256540.15271@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jonathan Gonzalez <jgonzalez@linets.cl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2014-01-30 at 12:58 -0800, David Rientjes wrote:
> On Thu, 30 Jan 2014, Sasha Levin wrote:
> 
> > VM_BUG_ON_PAGE is just a VM_BUG_ON that does dump_page before the BUG().
> > 
> > The only reason to use VM_BUG_ON instead of VM_BUG_ON_PAGE is if the page
> > you're working
> > with doesn't make sense/isn't useful as debug output.
> > 
> > If doing a dump_page is causing issues somewhere then dump_pages should be
> > fixed - instead
> > of hiding the problem under the rug by not using it.
> > 
> 
> It sounds like dump_page() isn't necessarily at fault itself but rather 
> that using it is opening a race even wider that causes this failure to 
> occur more often than it normally would.

It turns out this issue goes way back, you just have try hard enough to
trigger it under very specific conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
