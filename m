Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 314ED6B006C
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 22:04:25 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6818237dak.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 19:04:24 -0700 (PDT)
Date: Sun, 17 Jun 2012 10:04:10 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] mm/vmscan: cleanup comment error in balance_pgdat
Message-ID: <20120617020355.GA2168@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1339896438-5412-1-git-send-email-liwp.linux@gmail.com>
 <alpine.DEB.2.00.1206161852010.797@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206161852010.797@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org

On Sat, Jun 16, 2012 at 06:53:02PM -0700, David Rientjes wrote:
>On Sun, 17 Jun 2012, Wanpeng Li wrote:
>
>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>> 
>> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
>
>I think it would be better to do per-subsystem audits like this in a 
>single patch, i.e. one patch for mm/*, one patch for net/*, etc, get it 

thank you David

>acked, and then ask for it to be merged after an -rc1 release to avoid 
>lots of conflicts with other people's work.

You mean trivial maintainer only pull trivial patches for -rc1 release ?

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
