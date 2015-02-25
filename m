Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0958C6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 21:20:35 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so1397220pab.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 18:20:34 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id dk1si13573784pdb.78.2015.02.24.18.20.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 18:20:33 -0800 (PST)
Message-ID: <1424830824.6539.85.camel@stgolabs.net>
Subject: Re: [patch] mm, hugetlb: close race when setting PageTail for
 gigantic pages
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Tue, 24 Feb 2015 18:20:24 -0800
In-Reply-To: <alpine.DEB.2.10.1502241614480.4646@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502241614480.4646@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Luiz Capitulino <lcapitulino@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2015-02-24 at 16:16 -0800, David Rientjes wrote:
> Now that gigantic pages are dynamically allocatable, care must be taken
> to ensure that p->first_page is valid before setting PageTail.
> 
> If this isn't done, then it is possible to race and have compound_head()
> return NULL.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Davidlohr Bueso <dave@stgolabs.net>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
