Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2A626B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 10:35:49 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fb1so3690998pad.24
        for <linux-mm@kvack.org>; Thu, 01 May 2014 07:35:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id to1si17230636pab.322.2014.05.01.07.35.47
        for <linux-mm@kvack.org>;
        Thu, 01 May 2014 07:35:48 -0700 (PDT)
Message-ID: <53625BC3.3000804@intel.com>
Date: Thu, 01 May 2014 07:35:47 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/17] mm: page_alloc: Use unsigned int for order in more
 places
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-12-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 01:44 AM, Mel Gorman wrote:
> X86 prefers the use of unsigned types for iterators and there is a
> tendency to mix whether a signed or unsigned type if used for page
> order. This converts a number of sites in mm/page_alloc.c to use
> unsigned int for order where possible.

Does this actually generate any different code?  I'd actually expect
something like 'order' to be one of the easiest things for the compiler
to figure out an absolute range on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
