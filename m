Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C47296B025F
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 10:12:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r5so13013018wmr.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 07:12:55 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d2si33634300wjl.90.2016.06.07.07.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 07:12:53 -0700 (PDT)
Date: Tue, 7 Jun 2016 10:12:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/10] mm: base LRU balancing on an explicit cost model
Message-ID: <20160607141248.GD9978@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-8-hannes@cmpxchg.org>
 <1465266883.16365.154.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465266883.16365.154.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 10:34:43PM -0400, Rik van Riel wrote:
> On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> > Currently, scan pressure between the anon and file LRU lists is
> > balanced based on a mixture of reclaim efficiency and a somewhat
> > vague
> > notion of "value" of having certain pages in memory over others. That
> > concept of value is problematic, because it has caused us to count
> > any
> > event that remotely makes one LRU list more or less preferrable for
> > reclaim, even when these events are not directly comparable to each
> > other and impose very different costs on the system - such as a
> > referenced file page that we still deactivate and a referenced
> > anonymous page that we actually rotate back to the head of the list.
> > 
> 
> Well, patches 7-10 answered my question on patch 6 :)
> 
> I like this design.

Great! Thanks for reviewing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
