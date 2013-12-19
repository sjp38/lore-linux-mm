Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9522D6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 16:00:13 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so1551648qeb.25
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 13:00:13 -0800 (PST)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id k9si3959604qat.97.2013.12.19.13.00.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 13:00:12 -0800 (PST)
Received: by mail-vc0-f170.google.com with SMTP id la4so1002282vcb.1
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 13:00:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131219154157.GN21724@cmpxchg.org>
References: <20131219010847.E56B731C2B8@corp2gmr1-1.hot.corp.google.com>
	<20131219154157.GN21724@cmpxchg.org>
Date: Fri, 20 Dec 2013 06:00:11 +0900
Message-ID: <CA+55aFyMHRGv-pSnQG6UTRu6MBW0HN5L97d2ewbsE6T=iTm_uw@mail.gmail.com>
Subject: Re: [patch 15/24] mm: page_alloc: exclude unreclaimable allocations
 from zone fairness policy
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "# .39.x" <stable@kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>

On Thu, Dec 19, 2013 at 7:41 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> Linus, I did not see this patch show up in your tree yet

Oh, it's there. Commit 73f038b863dfe98acabc7c36c17342b84ad52e94.

> so if it's
> not too late, please consider merging the following patch instead to
> disable NUMA aspects of the fairness allocator entirely until we can
> agree on how it should behave, how it should be configurable etc.:

I'm ok with disabling it if that's what people want, but please send
an updated patch with acks etc on top of the current tree..

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
