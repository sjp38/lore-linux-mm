Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8892806EA
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 09:33:40 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f66so71746853ioe.12
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 06:33:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m5si6517893pgj.102.2017.04.20.06.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 06:33:39 -0700 (PDT)
Date: Thu, 20 Apr 2017 06:33:38 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 0/4] Replace mmap_sem by a range lock
Message-ID: <20170420133338.GC27790@bombadil.infradead.org>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

On Wed, Apr 19, 2017 at 02:18:23PM +0200, Laurent Dufour wrote:
> Following the series pushed by Davidlohr Bueso based on the Jan Kara's
> work [1] which introduces range locks, this series implements the
> first step of the attempt to replace the mmap_sem by a range lock.

Have you previously documented attempts to replace the mmap_sem by an
existing lock type before introducing a new (and frankly weird) lock?
My initial question is "Why not use RCU for this?" -- the rxrpc code
uses an rbtree protected by RCU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
