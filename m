Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 538076B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 09:10:10 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so3218584wme.5
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 06:10:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m88si3155460wmc.159.2016.12.02.06.10.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 06:10:09 -0800 (PST)
Date: Fri, 2 Dec 2016 15:10:06 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH v2 0/7] Speculative page faults
Message-ID: <20161202141006.GO6830@dhcp22.suse.cz>
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Linux MM <linux-mm@kvack.org>

On Fri 18-11-16 12:08:44, Laurent Dufour wrote:
> This is a port on kernel 4.8 of the work done by Peter Zijlstra to
> handle page fault without holding the mm semaphore.
> 
> http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
> 
> This series is not yet functional, I'm sending it to get feedback
> before going forward in the wrong direction. It's building on top of
> the 4.8 kernel but some task remain stuck at runtime, so there is
> still need for additional work. 
> 
> According to the review made by Kirill A. Shutemov on the Peter's
> work, there are still pending issues around the VMA sequence count
> management. I'll look at it right now.
> 
> Kirill, Peter, if you have any tips on the place where VMA sequence
> count should be handled, please advise.

I believe that a highlevel description of the change would be _more_
than welcome. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
