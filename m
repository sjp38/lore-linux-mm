Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B11D6B0399
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:09:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c5so12920450wmi.0
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:09:51 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id 59si20050568wrn.36.2017.03.19.13.09.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 13:09:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 81DF198D0B
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:09:49 +0000 (UTC)
Date: Sun, 19 Mar 2017 20:09:42 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 11/16] mm/hmm/mirror: helper to snapshot CPU page table v2
Message-ID: <20170319200942.GI2774@techsingularity.net>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-12-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1489680335-6594-12-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Thu, Mar 16, 2017 at 12:05:30PM -0400, J?r?me Glisse wrote:
> This does not use existing page table walker because we want to share
> same code for our page fault handler.
> 
> Changes since v1:
>   - Use spinlock instead of rcu synchronized list traversal
> 

Didn't look too closely here because pagetable walking code tends to have
few surprises but presumably there will be some 5-level page table
updates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
