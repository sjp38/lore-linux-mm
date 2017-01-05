Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B17FB6B025E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 17:54:09 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c186so70096614pfb.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:54:09 -0800 (PST)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id q2si72098308pga.234.2017.01.05.14.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 14:54:08 -0800 (PST)
Received: by mail-pg0-x232.google.com with SMTP id g1so205986898pgn.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:54:08 -0800 (PST)
Date: Thu, 5 Jan 2017 14:54:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: add new background defrag option
In-Reply-To: <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
Message-ID: <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com> <20170105101330.bvhuglbbeudubgqb@techsingularity.net> <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 5 Jan 2017, Vlastimil Babka wrote:

> Hmm that's probably why it's hard to understand, because "madvise
> request" is just setting a vma flag, and the THP allocation (and defrag)
> still happens at fault.
> 
> I'm not a fan of either name, so I've tried to implement my own
> suggestion. Turns out it was easier than expected, as there's no kernel
> boot option for "defer", just for "enabled", so that particular worry
> was unfounded.
> 
> And personally I think that it's less confusing when one can enable defer
> and madvise together (and not any other combination), than having to dig
> up the difference between "defer" and "background".
> 

I think allowing only two options to be combined amongst four available 
solo options is going to be confusing and then even more difficult for the 
user to understand what happens when they are combined.  Thus, I think 
these options should only have one settable mode as they have always done.

The kernel implementation takes less of a priority to userspace 
simplicitly, imo, and my patch actually cleans up much of the existing 
code and ends up adding fewer lines that yours.  I consider it an 
improvement in itself.  I don't see the benefit of allowing combined 
options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
