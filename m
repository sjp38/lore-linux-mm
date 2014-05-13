Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 95DE06B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 10:29:32 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id t59so362999yho.29
        for <linux-mm@kvack.org>; Tue, 13 May 2014 07:29:32 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id a48si20460589yhd.83.2014.05.13.07.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 07:29:32 -0700 (PDT)
Date: Tue, 13 May 2014 10:29:24 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 18/19] mm: Non-atomically mark page accessed during page
 cache allocation where possible
Message-ID: <20140513142924.GA5097@thunk.org>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-19-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399974350-11089-19-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

Acked-by: "Theodore Ts'o" <tytso@mit.edu>

Thanks!!

				- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
