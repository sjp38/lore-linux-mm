Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5250E6B03BE
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:37:40 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id g184so31770349oif.6
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:37:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o4si3378492oif.283.2017.04.20.07.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 07:37:39 -0700 (PDT)
Date: Thu, 20 Apr 2017 16:37:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 4/4] Change mmap_sem to range lock
Message-ID: <20170420143736.mvj6bpwsr4w3fjwk@hirez.programming.kicks-ass.net>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
 <1492698500-24219-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1492698500-24219-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

On Thu, Apr 20, 2017 at 04:28:20PM +0200, Laurent Dufour wrote:
> [resent this patch which seems to have not reached the mailing lists]

Probably because its too big at ~180k ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
