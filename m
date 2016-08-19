Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62A9C6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 08:45:12 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so30779199lfw.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 05:45:12 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id 131si3846933wma.114.2016.08.19.05.45.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 05:45:11 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id C1EC398A93
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 12:45:10 +0000 (UTC)
Date: Fri, 19 Aug 2016 13:45:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: Add WARN_ON for possibility of infinite loop if
 empty lists in free_pcppages_bulk'
Message-ID: <20160819124508.GM8119@techsingularity.net>
References: <1471608918-5101-1-git-send-email-pagupta@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1471608918-5101-1-git-send-email-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, vbabka@suse.cz, riel@redhat.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, izumi.taku@jp.fujitsu.com

On Fri, Aug 19, 2016 at 05:45:18PM +0530, Pankaj Gupta wrote:
> While debugging issue in realtime kernel i found a scenario
> which resulted in infinite loop resulting because of empty pcp->lists
> and valid 'to_free' value. This patch is to add 'WARN_ON' in function
> 'free_pcppages_bulk' if there is possibility of infinite loop because 
> of any bug in code.
> 

What was the bug that allowed this situation to occur? It would imply
the pcp count was somehow out of sync.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
