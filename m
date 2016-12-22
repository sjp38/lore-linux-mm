Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5C156B03F6
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 03:31:31 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so34587129wmf.3
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 00:31:31 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id rl18si30954317wjb.99.2016.12.22.00.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 00:31:30 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id m203so34687014wma.3
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 00:31:30 -0800 (PST)
Date: Thu, 22 Dec 2016 11:31:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161222083128.GB32480@node.shutemov.name>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 21, 2016 at 04:21:54PM -0800, David Rientjes wrote:
> Currently, when defrag is set to "madvise", thp allocations will direct
> reclaim.  However, when defrag is set to "defer", all thp allocations do
> not attempt reclaim regardless of MADV_HUGEPAGE.
> 
> This patch always directly reclaims for MADV_HUGEPAGE regions when defrag
> is not set to "never."  The idea is that MADV_HUGEPAGE regions really
> want to be backed by hugepages and are willing to endure the latency at
> fault as it was the default behavior prior to commit 444eb2a449ef ("mm:
> thp: set THP defrag by default to madvise and add a stall-free defrag
> option").
> 
> In this form, "defer" is a stronger, more heavyweight version of
> "madvise".
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Makes senses to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
