Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id D75B3828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 12:28:03 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id w104so104250528qge.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 09:28:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b22si12747270qkj.108.2016.03.18.09.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Mar 2016 09:28:03 -0700 (PDT)
Date: Fri, 18 Mar 2016 12:27:59 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20160318162759.GB21334@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
 <20160116174953.GU31137@redhat.com>
 <alpine.LSU.2.11.1601180014320.1538@eggly.anvils>
 <alpine.LSU.2.11.1603171413420.8342@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603171413420.8342@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>

Hello Hugh,

On Thu, Mar 17, 2016 at 02:34:23PM -0700, Hugh Dickins wrote:
> Andrew, please ignore my reservations about Andrea's KSM max sharing
> patch.  The diversions I created (IPIs etc), and my rash promise to
> think about it more, are serving no purpose but to delay a fix to a
> real problem.  Even if this fix is not quite what I dreamt of, it has
> the great commendation of being self-contained within ksm.c, affecting
> nothing else: so long as Andrea has time to support it, I think we're

I'll have time to support if if any problem arises yes.

> good with it.  Let Mel or I come up with better when we've devised it:
> but I doubt that will be soon (I got no further on what else to do
> about the compaction-migration case).

Agreed, the page migration case is what made me lean towards this self
contained solution, and then it has the benefit of solving all other
cases at the same time.

On the plus side the rmap_walk can remain "atomic" this way, so it may
generally result in higher reliability not having to break it in the
middle just because it's taking too long. This way there will be one
less unknown variable into the equation. We could still relax it in
the future if we'll need, but we won't be forced to.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
