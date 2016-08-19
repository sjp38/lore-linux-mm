Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCB96B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:07:32 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j124so85084960ith.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:07:32 -0700 (PDT)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id l193si4701583ita.54.2016.08.19.06.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 06:07:31 -0700 (PDT)
Date: Fri, 19 Aug 2016 09:07:21 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <945408416.2306040.1471612041111.JavaMail.zimbra@redhat.com>
In-Reply-To: <20160819124508.GM8119@techsingularity.net>
References: <1471608918-5101-1-git-send-email-pagupta@redhat.com> <20160819124508.GM8119@techsingularity.net>
Subject: Re: [PATCH] mm: Add WARN_ON for possibility of infinite loop if
 empty lists in free_pcppages_bulk'
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, vbabka@suse.cz, riel@redhat.com, hannes@cmpxchg.org, iamjoonsoo kim <iamjoonsoo.kim@lge.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, izumi taku <izumi.taku@jp.fujitsu.com>


> 
> On Fri, Aug 19, 2016 at 05:45:18PM +0530, Pankaj Gupta wrote:
> > While debugging issue in realtime kernel i found a scenario
> > which resulted in infinite loop resulting because of empty pcp->lists
> > and valid 'to_free' value. This patch is to add 'WARN_ON' in function
> > 'free_pcppages_bulk' if there is possibility of infinite loop because
> > of any bug in code.
> > 
> 
> What was the bug that allowed this situation to occur? It would imply
> the pcp count was somehow out of sync.

Yes pcp count was out of sync. It was a bug in the downstream code.
> 
> --
> Mel Gorman
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
