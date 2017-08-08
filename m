Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25DD96B0494
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:16:09 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c74so28189435iod.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:16:09 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f196si1600893itc.41.2017.08.08.06.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 06:16:08 -0700 (PDT)
Date: Tue, 8 Aug 2017 15:15:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v5 05/11] mm: fix lock dependency against
 mapping->i_mmap_rwsem
Message-ID: <20170808131557.iyczqs4wzqanx35p@hirez.programming.kicks-ass.net>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <564749a2-a729-b927-7707-1cad897c418a@linux.vnet.ibm.com>
 <78d903c4-6e9f-e049-de60-6d1ccb45ff92@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <78d903c4-6e9f-e049-de60-6d1ccb45ff92@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Tue, Aug 08, 2017 at 02:20:23PM +0200, Laurent Dufour wrote:
> This is an option, but the previous one was signed by Peter, and I'd prefer
> to keep his unchanged and add this new one to fix that.
> Again this is to ease the review.

You can always add something like:

[ldufour: fixed lockdep complaint]

Before your SoB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
