Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0F94E6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 16:12:43 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so277539pad.23
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 13:12:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kj7si2244135pab.160.2014.08.13.13.12.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Aug 2014 13:12:43 -0700 (PDT)
Date: Wed, 13 Aug 2014 13:12:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Actually clear pmd_numa before invalidating
Message-Id: <20140813131241.3ced5ccaeec24fcd378a1ef6@linux-foundation.org>
In-Reply-To: <100D68C7BA14664A8938383216E40DE0407D0CA2@FMSMSX114.amr.corp.intel.com>
References: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
	<20140813125951.7619f8e908eefb99c40827c4@linux-foundation.org>
	<100D68C7BA14664A8938383216E40DE0407D0CA2@FMSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, 13 Aug 2014 20:04:02 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@intel.com> wrote:

> The commit log for 67f87463d3 explains what the runtime effects should have been.

No it doesn't.  In fact the sentence "The existing caller of
pmdp_invalidate should handle it but it's an inconsistent state for a
PMD." makes me suspect there are no end-user visible effects.

I don't know why we chose to backport that one into -stable and I don't
know why we should backport this one either.

Greg (and others) will look at this changelog and wonder "why".  It
should tell them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
