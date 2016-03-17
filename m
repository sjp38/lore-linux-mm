Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C1E4D6B007E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 17:50:25 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 4so6654500pfd.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 14:50:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id be6si14922398pad.69.2016.03.17.14.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 14:50:24 -0700 (PDT)
Date: Thu, 17 Mar 2016 14:50:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-Id: <20160317145023.537752f7bd4e3cd2e0ab03a8@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1603171413420.8342@eggly.anvils>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
	<1447181081-30056-2-git-send-email-aarcange@redhat.com>
	<alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
	<20160116174953.GU31137@redhat.com>
	<alpine.LSU.2.11.1601180014320.1538@eggly.anvils>
	<alpine.LSU.2.11.1603171413420.8342@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>

On Thu, 17 Mar 2016 14:34:23 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> On Mon, 18 Jan 2016, Hugh Dickins wrote:
> > On Sat, 16 Jan 2016, Andrea Arcangeli wrote:
> > > Hello Hugh,
> > > 
> > > Thanks a lot for reviewing this.
> > 
> > And thanks for your thorough reply, though I take issue with some of it :)
> > 
> [...]
> > 
> > I'll think about it more.
> 
> Andrew, please ignore my reservations about Andrea's KSM max sharing
> patch.  The diversions I created (IPIs etc), and my rash promise to
> think about it more, are serving no purpose but to delay a fix to a
> real problem.  Even if this fix is not quite what I dreamt of, it has
> the great commendation of being self-contained within ksm.c, affecting
> nothing else: so long as Andrea has time to support it, I think we're
> good with it.  Let Mel or I come up with better when we've devised it:
> but I doubt that will be soon (I got no further on what else to do
> about the compaction-migration case).

OK, thanks, I'll send it Linuswards next week.

http://ozlabs.org/~akpm/mmots/broken-out/ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
http://ozlabs.org/~akpm/mmots/broken-out/ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-2.patch
http://ozlabs.org/~akpm/mmots/broken-out/ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-3.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
