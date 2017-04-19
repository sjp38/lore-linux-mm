Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED6E52806D8
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:30:56 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 70so9218354ita.22
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 05:30:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n75si2515232pfi.284.2017.04.19.05.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 05:30:56 -0700 (PDT)
Date: Wed, 19 Apr 2017 14:30:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 2/4] Deactivate mmap_sem assert
Message-ID: <20170419123051.GA5730@worktop>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
 <582009a3f9459de3d8def1e76db46e815ea6153c.1492595897.git.ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <582009a3f9459de3d8def1e76db46e815ea6153c.1492595897.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

On Wed, Apr 19, 2017 at 02:18:25PM +0200, Laurent Dufour wrote:
> When mmap_sem will be moved to a range lock, some assertion done in
> the code are no more valid, like the one ensuring mmap_sem is held.
> 

Why are they no longer valid?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
