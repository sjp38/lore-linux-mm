Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 526936B0071
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:43:05 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so172850600wgb.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:43:04 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id h5si17268134wie.91.2015.03.24.07.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 07:43:03 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 24 Mar 2015 14:43:02 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4BBF01B0806B
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 14:43:26 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2OEh0jF58065020
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 14:43:00 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2OEgw2a027513
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:42:59 -0600
Message-ID: <551177F0.3070006@de.ibm.com>
Date: Tue, 24 Mar 2015 15:42:56 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Remove usages of ACCESS_ONCE
References: <1427150680.2515.36.camel@j-VirtualBox>
In-Reply-To: <1427150680.2515.36.camel@j-VirtualBox>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, Rik van Riel <riel@redhat.com>

Am 23.03.2015 um 23:44 schrieb Jason Low:
> Commit 38c5ce936a08 converted ACCESS_ONCE usage in gup_pmd_range() to
> READ_ONCE, since ACCESS_ONCE doesn't work reliably on non-scalar types.
> 
> This patch removes the rest of the usages of ACCESS_ONCE, and use
> READ_ONCE for the read accesses. This also makes things cleaner,
> instead of using separate/multiple sets of APIs.
> 
> Signed-off-by: Jason Low <jason.low2@hp.com>

Reviewed-by: Christian Borntraeger <borntraeger@de.ibm.com>

one remark or question:

> -	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
> +	anon_mapping = (unsigned long)READ_ONCE(page->mapping);

Were the white space changes intentional? IIRC checkpatch does prefer
it your way and you have changed several places - so I assume yes.
Either way, its probably fine to change that along.

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
