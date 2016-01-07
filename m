Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id EBF28828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 16:29:13 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id g73so68425396ioe.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 13:29:13 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id p4si9864790igg.41.2016.01.07.13.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 13:29:13 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id yy13so175492324pab.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 13:29:13 -0800 (PST)
Date: Thu, 7 Jan 2016 13:29:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 9/9] mm, oom: print symbolic gfp_flags in oom
 warning
In-Reply-To: <1448368581-6923-10-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1601071327490.20990@chino.kir.corp.google.com>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz> <1448368581-6923-10-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Tue, 24 Nov 2015, Vlastimil Babka wrote:

> It would be useful to translate gfp_flags into string representation when
> printing in case of an OOM, especially as the flags have been undergoing some
> changes recently and the script ./scripts/gfp-translate needs a matching source
> version to be accurate.
> 
> Example output:
> 
> a.out invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
> 

Is there a way that we can keep the order of the fields so that anything 
parsing the kernel log for oom kills doesn't break?  The messages printed 
to the kernel log are the only (current) way to determine that the kernel 
killed something so we should be careful not to break anything parsing 
them, and this is a common line to look for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
