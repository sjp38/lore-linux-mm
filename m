Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8192F6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 10:00:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so18618047wmz.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 07:00:29 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id 8si4136621wmu.68.2016.08.19.07.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 07:00:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id D0D131C2AF0
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 15:00:27 +0100 (IST)
Date: Fri, 19 Aug 2016 15:00:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: Add WARN_ON for possibility of infinite loop if
 empty lists in free_pcppages_bulk'
Message-ID: <20160819140026.GN8119@techsingularity.net>
References: <1471608918-5101-1-git-send-email-pagupta@redhat.com>
 <20160819124508.GM8119@techsingularity.net>
 <945408416.2306040.1471612041111.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <945408416.2306040.1471612041111.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, vbabka@suse.cz, riel@redhat.com, hannes@cmpxchg.org, iamjoonsoo kim <iamjoonsoo.kim@lge.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, izumi taku <izumi.taku@jp.fujitsu.com>

On Fri, Aug 19, 2016 at 09:07:21AM -0400, Pankaj Gupta wrote:
> 
> > 
> > On Fri, Aug 19, 2016 at 05:45:18PM +0530, Pankaj Gupta wrote:
> > > While debugging issue in realtime kernel i found a scenario
> > > which resulted in infinite loop resulting because of empty pcp->lists
> > > and valid 'to_free' value. This patch is to add 'WARN_ON' in function
> > > 'free_pcppages_bulk' if there is possibility of infinite loop because
> > > of any bug in code.
> > > 
> > 
> > What was the bug that allowed this situation to occur? It would imply
> > the pcp count was somehow out of sync.
> 
> Yes pcp count was out of sync. It was a bug in the downstream code.

If the bug is not in the mainline code, I think it would be inappropriate
to add unnecessary code to a relatively hot path. At most, it should be
a VM_BUG_ON but the soft lockup should be clear enough.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
