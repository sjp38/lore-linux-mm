Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 824606B002F
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 02:12:08 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p9Q6C5dk001610
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:12:05 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz29.hot.corp.google.com with ESMTP id p9Q6BebS027379
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:12:03 -0700
Received: by pzk4 with SMTP id 4so5373037pzk.6
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:12:03 -0700 (PDT)
Date: Tue, 25 Oct 2011 23:12:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com> <20111025090956.GA10797@suse.de> <alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com> <CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
 <alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 25 Oct 2011, David Rientjes wrote:

> Ok, so __GFP_NORETRY it is.  Just make sure that when 
> pm_restrict_gfp_mask() masks off __GFP_IO and __GFP_FS that it also sets 
> __GFP_NORETRY even though the name of the function no longer seems 
> appropriate anymore.
> 

Or, rather, when pm_restrict_gfp_mask() clears __GFP_IO and __GFP_FS that 
it also has the same behavior as __GFP_NORETRY in should_alloc_retry() by 
setting a variable in file scope.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
