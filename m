Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 536396B0070
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 21:53:05 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8338769pbb.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 18:53:04 -0700 (PDT)
Date: Sat, 16 Jun 2012 18:53:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/vmscan: cleanup comment error in balance_pgdat
In-Reply-To: <1339896438-5412-1-git-send-email-liwp.linux@gmail.com>
Message-ID: <alpine.DEB.2.00.1206161852010.797@chino.kir.corp.google.com>
References: <1339896438-5412-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>

On Sun, 17 Jun 2012, Wanpeng Li wrote:

> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

I think it would be better to do per-subsystem audits like this in a 
single patch, i.e. one patch for mm/*, one patch for net/*, etc, get it 
acked, and then ask for it to be merged after an -rc1 release to avoid 
lots of conflicts with other people's work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
