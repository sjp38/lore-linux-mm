Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 224736B00BE
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 01:01:40 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fb1so10054676pad.37
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 22:01:39 -0800 (PST)
Received: from psmtp.com ([74.125.245.105])
        by mx.google.com with SMTP id gn4si15925447pbc.171.2013.11.05.22.01.36
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 22:01:37 -0800 (PST)
Received: by mail-ea0-f172.google.com with SMTP id r16so4729504ead.31
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 22:01:34 -0800 (PST)
Date: Wed, 6 Nov 2013 07:01:32 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131106060132.GB24044@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <20131103101234.GB5330@gmail.com>
 <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
 <20131104070500.GE13030@gmail.com>
 <20131104142001.GE9299@localhost.localdomain>
 <20131104175245.GA19517@gmail.com>
 <20131104181012.GK9299@localhost.localdomain>
 <20131105082450.GA10127@gmail.com>
 <20131105142707.GC30283@krava.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131105142707.GC30283@krava.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Olsa <jolsa@redhat.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, David Ahern <dsahern@gmail.com>, Arnaldo Carvalho de Melo <acme@redhat.com>


* Jiri Olsa <jolsa@redhat.com> wrote:

> > But success primarily depends on how useful the tooling UI turns out 
> > to be: create a nice Slang or GTK UI for kprobes and triggers, and/or 
> > turn it into a really intuitive command line UI, and people will use 
> > it.
> > 
> > I think annotated assembly/source output is a really nice match for 
> > triggers and kprobes, so I'd suggest the Slang TUI route ...
> 
> yep, current toggling command line UI is not much user friendly
> 
> but perhaps we should leave it there (because it seems it wont get much 
> better anyway) and focus more on Slang UI as the target one..
> 
> CCing Arnaldo ;-)

Btw., I think we should do the TUI interface _before_ we can merge the 
kernel changes. Frankly, 'not very user friendly' means that it's not used 
(and tested) much - which begs the question: why merge the feature at all?

Making a new kernel feature usable to as many people as possible must be a 
primary concern, not an afterthought.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
