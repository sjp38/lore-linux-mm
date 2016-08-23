Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E17D6B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 04:48:51 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n6so227545029qtn.2
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 01:48:51 -0700 (PDT)
Received: from mx6-phx2.redhat.com (mx6-phx2.redhat.com. [209.132.183.39])
        by mx.google.com with ESMTPS id 63si1506094qkd.218.2016.08.23.01.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 01:48:51 -0700 (PDT)
Date: Tue, 23 Aug 2016 04:48:40 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <529861221.2662345.1471942120576.JavaMail.zimbra@redhat.com>
In-Reply-To: <20160819140026.GN8119@techsingularity.net>
References: <1471608918-5101-1-git-send-email-pagupta@redhat.com> <20160819124508.GM8119@techsingularity.net> <945408416.2306040.1471612041111.JavaMail.zimbra@redhat.com> <20160819140026.GN8119@techsingularity.net>
Subject: Re: [PATCH] mm: Add WARN_ON for possibility of infinite loop if
 empty lists in free_pcppages_bulk'
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, vbabka@suse.cz, riel@redhat.com, hannes@cmpxchg.org, iamjoonsoo kim <iamjoonsoo.kim@lge.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, izumi taku <izumi.taku@jp.fujitsu.com>


> > > > While debugging issue in realtime kernel i found a scenario
> > > > which resulted in infinite loop resulting because of empty pcp->lists
> > > > and valid 'to_free' value. This patch is to add 'WARN_ON' in function
> > > > 'free_pcppages_bulk' if there is possibility of infinite loop because
> > > > of any bug in code.
> > > > 
> > > 
> > > What was the bug that allowed this situation to occur? It would imply
> > > the pcp count was somehow out of sync.
> > 
> > Yes pcp count was out of sync. It was a bug in the downstream code.
> 
> If the bug is not in the mainline code, I think it would be inappropriate
> to add unnecessary code to a relatively hot path. At most, it should be
> a VM_BUG_ON but the soft lockup should be clear enough.

yes 'VM_BUG_ON' is right thing here. This could help in realtime kernel where
'free_pcppages_bulk' is divided into two functions 'isolate_pcp_pages' and 
'free_pcppages_bulk' where 'isolate_pcp_pages' isolate the 'batch/count' number
of pages and 'free_pcppages_bulk' just free these pages.

I was just thinking if there is any possibility of out of sync with count and temporary
list this might help. But looking more at the code does not seems like there is any 
chance until any other potential bug somewhere else in code result this scenario.

I will drop this patch.

Thanks for the review.

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
