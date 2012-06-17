Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 138486B006C
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 22:11:13 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6822178dak.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 19:11:12 -0700 (PDT)
Date: Sat, 16 Jun 2012 19:11:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/vmscan: cleanup comment error in balance_pgdat
In-Reply-To: <20120617020355.GA2168@kernel>
Message-ID: <alpine.DEB.2.00.1206161908000.797@chino.kir.corp.google.com>
References: <1339896438-5412-1-git-send-email-liwp.linux@gmail.com> <alpine.DEB.2.00.1206161852010.797@chino.kir.corp.google.com> <20120617020355.GA2168@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Sun, 17 Jun 2012, Wanpeng Li wrote:

> >acked, and then ask for it to be merged after an -rc1 release to avoid 
> >lots of conflicts with other people's work.
> 
> You mean trivial maintainer only pull trivial patches for -rc1 release ?
> 

It all depends on how big your patch turns out to be; if it's sufficiently 
large then it would probably be best to wait for -rc1, rebase your patch 
to it, carry any acks that you have received, and ask it to be merged for 
-rc2 to reduce conflicts with other code being pushed during the merge 
window.  Otherwise, just make a big patch and ask Andrew to carry it in 
the -mm tree but make sure to base it off linux-next as it sits today.  
You'll want to clone 
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
