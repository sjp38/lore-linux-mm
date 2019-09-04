Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FE27C3A5A4
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:02:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB6F422CF7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:02:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="jhBWG15A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB6F422CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F0BA6B0003; Wed,  4 Sep 2019 01:02:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A2FF6B0006; Wed,  4 Sep 2019 01:02:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56A696B0007; Wed,  4 Sep 2019 01:02:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id 35A3A6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 01:02:44 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id DC6C9AC1C
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:02:43 +0000 (UTC)
X-FDA: 75896043006.22.paint59_34dac328d2e31
X-HE-Tag: paint59_34dac328d2e31
X-Filterd-Recvd-Size: 9530
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:02:43 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id k1so1655478pls.11
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 22:02:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pDj1bZcKWdYkCPbWgz/Pz2qMGxk7UgTAcQYM9ROVqw0=;
        b=jhBWG15AlqK3xprU+HODJGbDECbvG7FlMM8fuoD8/LWLxPXWYohHnPZOtxNQ5RgeXK
         fEoCXJGVrlmBWkOM+IzI8pKDCqx1LTa7IvPd2jPNU3D9QdrV7tnq2n6pBlO2TsUHn0TN
         Dt3bmqAEc5aau0JUNifmRnKjgGhzlqklSKEVs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=pDj1bZcKWdYkCPbWgz/Pz2qMGxk7UgTAcQYM9ROVqw0=;
        b=RPZnjh+CW/vGsOyQv2lA/jes3BIO6n+I1NoF5kVvkzop/4EKbBxokiut8uAoinBFw9
         gzguOlMJJ1QVZ4ddgQRI7+gUNjilzT7waInRCzRVdy9QN0UTDAjrSuo7u+lkjKyuLJV5
         hOh4caAyfATg1T0ch0qB/qag93esk0g1a8k0Xcq3V8Rf44DAskxsOSen5wEOdXxfS5Lt
         azy1LpPB2tPywrDHpwzxEoTdh9qrHz9Ldjf1TRdqhoj087ShkxGqCKiVYkI6ZComsead
         OeF9u3U9hnFAUvuJcJVV3PIOVXuItwQZ4VXlE9UnJ0aTo3jpK69ZTknTNl0HECo9V4Bn
         PZtw==
X-Gm-Message-State: APjAAAWSK7SXMpZ5345bXhim19h4QFAvgCCz+SHqMCinzFsyWR5av2Gh
	wOQd2JhVICBwYTOpxd0KKnoXqw==
X-Google-Smtp-Source: APXvYqwFAoBQdwlA0QwMATvwlTnwADSgKV4Rci0PHl20Z+apUh4ALoinpglyCuZdFVxd1SkpK8eczQ==
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr39733162plb.237.1567573361845;
        Tue, 03 Sep 2019 22:02:41 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id q132sm16031769pfq.16.2019.09.03.22.02.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 22:02:41 -0700 (PDT)
Date: Wed, 4 Sep 2019 01:02:40 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Tim Murray <timmurray@google.com>,
	Carmen Jackson <carmenjackson@google.com>, mayankgupta@google.com,
	Daniel Colascione <dancol@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	kernel-team <kernel-team@android.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>,
	Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.cz>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190904050240.GD144846@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 09:44:51PM -0700, Suren Baghdasaryan wrote:
> On Tue, Sep 3, 2019 at 1:09 PM Joel Fernandes (Google)
> <joel@joelfernandes.org> wrote:
> >
> > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > memory hogs. Several Android teams have been using this patch in various
> > kernel trees for half a year now. Many reported to me it is really
> > useful so I'm posting it upstream.
> >
> > Initial patch developed by Tim Murray. Changes I made from original patch:
> > o Prevent any additional space consumed by mm_struct.
> > o Keep overhead low by checking if tracing is enabled.
> > o Add some noise reduction and lower overhead by emitting only on
> >   threshold changes.
> >
> > Co-developed-by: Tim Murray <timmurray@google.com>
> > Signed-off-by: Tim Murray <timmurray@google.com>
> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> >
> > ---
> >
> > v1->v2: Added more commit message.
> >
> > Cc: carmenjackson@google.com
> > Cc: mayankgupta@google.com
> > Cc: dancol@google.com
> > Cc: rostedt@goodmis.org
> > Cc: minchan@kernel.org
> > Cc: akpm@linux-foundation.org
> > Cc: kernel-team@android.com
> >
> >  include/linux/mm.h          | 14 +++++++++++---
> >  include/trace/events/kmem.h | 21 +++++++++++++++++++++
> >  mm/memory.c                 | 20 ++++++++++++++++++++
> >  3 files changed, 52 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0334ca97c584..823aaf759bdb 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1671,19 +1671,27 @@ static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
> >         return (unsigned long)val;
> >  }
> >
> > +void mm_trace_rss_stat(int member, long count, long value);
> > +
> >  static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
> >  {
> > -       atomic_long_add(value, &mm->rss_stat.count[member]);
> > +       long count = atomic_long_add_return(value, &mm->rss_stat.count[member]);
> > +
> > +       mm_trace_rss_stat(member, count, value);
> >  }
> >
> >  static inline void inc_mm_counter(struct mm_struct *mm, int member)
> >  {
> > -       atomic_long_inc(&mm->rss_stat.count[member]);
> > +       long count = atomic_long_inc_return(&mm->rss_stat.count[member]);
> > +
> > +       mm_trace_rss_stat(member, count, 1);
> >  }
> >
> >  static inline void dec_mm_counter(struct mm_struct *mm, int member)
> >  {
> > -       atomic_long_dec(&mm->rss_stat.count[member]);
> > +       long count = atomic_long_dec_return(&mm->rss_stat.count[member]);
> > +
> > +       mm_trace_rss_stat(member, count, -1);
> >  }
> >
> >  /* Optimized variant when page is already known not to be PageAnon */
> > diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> > index eb57e3037deb..8b88e04fafbf 100644
> > --- a/include/trace/events/kmem.h
> > +++ b/include/trace/events/kmem.h
> > @@ -315,6 +315,27 @@ TRACE_EVENT(mm_page_alloc_extfrag,
> >                 __entry->change_ownership)
> >  );
> >
> > +TRACE_EVENT(rss_stat,
> > +
> > +       TP_PROTO(int member,
> > +               long count),
> > +
> > +       TP_ARGS(member, count),
> > +
> > +       TP_STRUCT__entry(
> > +               __field(int, member)
> > +               __field(long, size)
> > +       ),
> > +
> > +       TP_fast_assign(
> > +               __entry->member = member;
> > +               __entry->size = (count << PAGE_SHIFT);
> > +       ),
> > +
> > +       TP_printk("member=%d size=%ldB",
> > +               __entry->member,
> > +               __entry->size)
> > +       );
> >  #endif /* _TRACE_KMEM_H */
> >
> >  /* This part must be outside protection */
> > diff --git a/mm/memory.c b/mm/memory.c
> > index e2bb51b6242e..9d81322c24a3 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -72,6 +72,8 @@
> >  #include <linux/oom.h>
> >  #include <linux/numa.h>
> >
> > +#include <trace/events/kmem.h>
> > +
> >  #include <asm/io.h>
> >  #include <asm/mmu_context.h>
> >  #include <asm/pgalloc.h>
> > @@ -140,6 +142,24 @@ static int __init init_zero_pfn(void)
> >  }
> >  core_initcall(init_zero_pfn);
> >
> > +/*
> > + * This threshold is the boundary in the value space, that the counter has to
> > + * advance before we trace it. Should be a power of 2. It is to reduce unwanted
> > + * trace overhead. The counter is in units of number of pages.
> > + */
> > +#define TRACE_MM_COUNTER_THRESHOLD 128
> 
> IIUC the counter has to change by 128 pages (512kB assuming 4kB pages)
> before the change gets traced. Would it make sense to make this step
> size configurable? For a system with limited memory size change of
> 512kB might be considerable while on systems with plenty of memory
> that might be negligible. Not even mentioning possible difference in
> page sizes. Maybe something like
> /sys/kernel/debug/tracing/rss_step_order with
> TRACE_MM_COUNTER_THRESHOLD=(1<<rss_step_order)?

I would not want to complicate this more to be honest. It is already a bit
complex, and I am not sure about the win in making it as configurable as you
seem to want. The "threshold" thing is just a slight improvement, it is not
aiming to be optimal. If in your tracing, this granularity is an issue, we
can visit it then.

thanks,

 - Joel



> > +void mm_trace_rss_stat(int member, long count, long value)
> > +{
> > +       long thresh_mask = ~(TRACE_MM_COUNTER_THRESHOLD - 1);
> > +
> > +       if (!trace_rss_stat_enabled())
> > +               return;
> > +
> > +       /* Threshold roll-over, trace it */
> > +       if ((count & thresh_mask) != ((count - value) & thresh_mask))
> > +               trace_rss_stat(member, count);
> > +}
> >
> >  #if defined(SPLIT_RSS_COUNTING)
> >
> > --
> > 2.23.0.187.g17f5b7556c-goog
> >
> > --
> > To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
> >

