Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2CC6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 18:20:09 -0400 (EDT)
Received: by wizk4 with SMTP id k4so172329423wiz.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 15:20:08 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id o1si14316035wix.88.2015.04.15.15.20.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 15:20:08 -0700 (PDT)
Date: Thu, 16 Apr 2015 00:20:06 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages
 when unmapping
Message-ID: <20150415222006.GS2366@two.firstfloor.org>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
 <1429094576-5877-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429094576-5877-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


I did a quick read and it looks good to me.

It's a bit ugly to bloat current with the ubc pointer,
but i guess there's no good way around that.

Also not nice to use GFP_ATOMIC for the allocation,
but again there's no way around it and it will
eventually recover if it fails. There may be
a slightly better GFP flag for this situation that
doesn't dip into the interrupt pools?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
