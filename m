Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A61016B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 13:38:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b87so3173485wmi.14
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:38:51 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id m194si12895930wmb.55.2017.04.10.10.38.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 10:38:50 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 22CCC989A1
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 17:38:50 +0000 (UTC)
Date: Mon, 10 Apr 2017 18:38:49 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
Message-ID: <20170410173849.ecy2ysm7twzgcm53@techsingularity.net>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
 <20170410135342.GD4618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170410135342.GD4618@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 10, 2017 at 03:53:42PM +0200, Michal Hocko wrote:
> > While this could be fixed with heavy locking, it's only necessary to
> > make a copy of the PMD on the stack during change_pmd_range and avoid
> > races. A new helper is created for this as the check if quite subtle and the
> > existing similar helpful is not suitable. This passed 154 hours of testing
> 
> s@helpful@helper@ I suspect
> 

Yes. I'll wait to see if there is more feedback and if not, resend unless
Andrew decides to pick it up and correct the mistake directly.

> > (usually triggers between 20 minutes and 24 hours) without detecting bad
> > PMDs or corruption. A basic test of an autonuma-intensive workload showed
> > no significant change in behaviour.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Cc: stable@vger.kernel.org
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 

Thanks.

> you will probably win the_longest_function_name_contest but I do not
> have much better suggestion.
> 

I know, it's not a type of function that yields a snappy name.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
