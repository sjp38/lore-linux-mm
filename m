Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 649D16B004D
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 22:15:04 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6824271dak.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 19:15:03 -0700 (PDT)
Date: Sun, 17 Jun 2012 10:14:46 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] mm/vmscan: cleanup comment error in balance_pgdat
Message-ID: <20120617021446.GB2168@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1339896438-5412-1-git-send-email-liwp.linux@gmail.com>
 <alpine.DEB.2.00.1206161852010.797@chino.kir.corp.google.com>
 <20120617020355.GA2168@kernel>
 <alpine.DEB.2.00.1206161908000.797@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206161908000.797@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org

On Sat, Jun 16, 2012 at 07:11:09PM -0700, David Rientjes wrote:
>On Sun, 17 Jun 2012, Wanpeng Li wrote:
>
>> >acked, and then ask for it to be merged after an -rc1 release to avoid 
>> >lots of conflicts with other people's work.
>> 
>> You mean trivial maintainer only pull trivial patches for -rc1 release ?
>> 
>
>It all depends on how big your patch turns out to be; if it's sufficiently 
>large then it would probably be best to wait for -rc1, rebase your patch 
>to it, carry any acks that you have received, and ask it to be merged for 
>-rc2 to reduce conflicts with other code being pushed during the merge 
>window.  Otherwise, just make a big patch and ask Andrew to carry it in 
>the -mm tree but make sure to base it off linux-next as it sits today.  
>You'll want to clone 
>git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git

Thank you David, thanks for your quick response.

Best Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
