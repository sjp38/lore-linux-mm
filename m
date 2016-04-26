Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF456B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 11:18:43 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id u2so31965421obx.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:18:43 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id ei6si3953610igb.99.2016.04.26.08.18.42
        for <linux-mm@kvack.org>;
        Tue, 26 Apr 2016 08:18:42 -0700 (PDT)
Date: Tue, 26 Apr 2016 10:18:41 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 14/18] prctl: make PR_SET_THP_DISABLE wait for mmap_sem
 killable
Message-ID: <20160426151841.GQ152091@stormcage.americas.sgi.com>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
 <1461675385-5934-15-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461675385-5934-15-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Alex Thorlton <athorlton@sgi.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Apr 26, 2016 at 02:56:21PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> PR_SET_THP_DISABLE requires mmap_sem for write. If the waiting
> task gets killed by the oom killer it would block oom_reaper from
> asynchronous address space reclaim and reduce the chances of timely OOM
> resolving. Wait for the lock in the killable mode and return with EINTR
> if the task got killed while waiting.
> 
> Cc: Alex Thorlton <athorlton@sgi.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me - I wrote that bit of code so I think this can get an:

Acked-by: Alex Thorlton <athorlton@sgi.com>

Thanks for Ccing me!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
