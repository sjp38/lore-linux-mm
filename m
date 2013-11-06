Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id EFFE66B00D6
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 09:03:42 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id wy17so5905503pbc.0
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 06:03:42 -0800 (PST)
Received: from psmtp.com ([74.125.245.166])
        by mx.google.com with SMTP id z1si17136523pbw.159.2013.11.06.06.03.40
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 06:03:41 -0800 (PST)
Received: by mail-ie0-f175.google.com with SMTP id aq17so16954122iec.6
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 06:03:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131106060132.GB24044@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
	<20131103101234.GB5330@gmail.com>
	<1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
	<20131104070500.GE13030@gmail.com>
	<20131104142001.GE9299@localhost.localdomain>
	<20131104175245.GA19517@gmail.com>
	<20131104181012.GK9299@localhost.localdomain>
	<20131105082450.GA10127@gmail.com>
	<20131105142707.GC30283@krava.brq.redhat.com>
	<20131106060132.GB24044@gmail.com>
Date: Wed, 6 Nov 2013 18:03:39 +0400
Message-ID: <CALYGNiNc__rWZGTdW-TZ2zp+HPziCiCj764JECP1tnvK4C0S8A@mail.gmail.com>
Subject: Re: [PATCH] mm: cache largest vma
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Jiri Olsa <jolsa@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, David Ahern <dsahern@gmail.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

Some time ago I've thought about caching vma on PTE's struct page.
This will work for all huge vmas not only for largest ones.

Of course this requires some reordering in do_page_fault because
currently it lookups vma before pte for obvious reason.


On Wed, Nov 6, 2013 at 10:01 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Jiri Olsa <jolsa@redhat.com> wrote:
>
>> > But success primarily depends on how useful the tooling UI turns out
>> > to be: create a nice Slang or GTK UI for kprobes and triggers, and/or
>> > turn it into a really intuitive command line UI, and people will use
>> > it.
>> >
>> > I think annotated assembly/source output is a really nice match for
>> > triggers and kprobes, so I'd suggest the Slang TUI route ...
>>
>> yep, current toggling command line UI is not much user friendly
>>
>> but perhaps we should leave it there (because it seems it wont get much
>> better anyway) and focus more on Slang UI as the target one..
>>
>> CCing Arnaldo ;-)
>
> Btw., I think we should do the TUI interface _before_ we can merge the
> kernel changes. Frankly, 'not very user friendly' means that it's not used
> (and tested) much - which begs the question: why merge the feature at all?
>
> Making a new kernel feature usable to as many people as possible must be a
> primary concern, not an afterthought.
>
> Thanks,
>
>         Ingo
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
