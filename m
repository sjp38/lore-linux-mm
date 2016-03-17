Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE996B007E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 17:34:35 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id x3so136953233pfb.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 14:34:35 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id vc15si6400695pab.8.2016.03.17.14.34.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 14:34:34 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id 4so6192951pfd.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 14:34:34 -0700 (PDT)
Date: Thu, 17 Mar 2016 14:34:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
In-Reply-To: <alpine.LSU.2.11.1601180014320.1538@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1603171413420.8342@eggly.anvils>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com> <1447181081-30056-2-git-send-email-aarcange@redhat.com> <alpine.LSU.2.11.1601141356080.13199@eggly.anvils> <20160116174953.GU31137@redhat.com>
 <alpine.LSU.2.11.1601180014320.1538@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>

On Mon, 18 Jan 2016, Hugh Dickins wrote:
> On Sat, 16 Jan 2016, Andrea Arcangeli wrote:
> > Hello Hugh,
> > 
> > Thanks a lot for reviewing this.
> 
> And thanks for your thorough reply, though I take issue with some of it :)
> 
[...]
> 
> I'll think about it more.

Andrew, please ignore my reservations about Andrea's KSM max sharing
patch.  The diversions I created (IPIs etc), and my rash promise to
think about it more, are serving no purpose but to delay a fix to a
real problem.  Even if this fix is not quite what I dreamt of, it has
the great commendation of being self-contained within ksm.c, affecting
nothing else: so long as Andrea has time to support it, I think we're
good with it.  Let Mel or I come up with better when we've devised it:
but I doubt that will be soon (I got no further on what else to do
about the compaction-migration case).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
