Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 320FD900015
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 19:26:37 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id a141so46941732oig.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 16:26:36 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id px7si5373611obc.58.2015.02.02.16.26.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 16:26:36 -0800 (PST)
Message-ID: <1422923185.14964.2.camel@stgolabs.net>
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 02 Feb 2015 16:26:25 -0800
In-Reply-To: <20150202143541.1efdd2b571413200cb9a4698@linux-foundation.org>
References: <20150202165525.GM2395@suse.de>
	 <20150202140506.392ff6920743f19ea44cff59@linux-foundation.org>
	 <20150202221824.GN2395@suse.de>
	 <20150202143541.1efdd2b571413200cb9a4698@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Mon, 2015-02-02 at 14:35 -0800, Andrew Morton wrote:
> On Mon, 2 Feb 2015 22:18:24 +0000 Mel Gorman <mgorman@suse.de> wrote:
> 
> > > Is there something
> > > preventing this from being addressed within glibc?
> >  
> > I doubt it other than I expect they'll punt it back and blame either the
> > application for being stupid or the kernel for being slow.
> 
> *Is* the application being stupid?  What is it actually doing? 
> Something like
> 
> pthread_routine()
> {
> 	p = malloc(X);
> 	do_some(work);
> 	free(p);

Ebizzy adds a time based loop in there. But yeah, pretty much a standard
pthread model.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
