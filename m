Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6087B6B2A66
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:45:24 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t9-v6so4675821qkl.2
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:45:24 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l67-v6si1999069qkc.192.2018.08.23.06.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 06:45:23 -0700 (PDT)
Subject: Re: [PATCH] xen/gntdev: fix up blockable calls to mn_invl_range_start
References: <20180823120707.10998-1-mhocko@kernel.org>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <565d0ef0-4723-bd1b-95de-cb9aba50fe20@oracle.com>
Date: Thu, 23 Aug 2018 09:46:40 -0400
MIME-Version: 1.0
In-Reply-To: <20180823120707.10998-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Juergen Gross <jgross@suse.com>

On 08/23/2018 08:07 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> 93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
> has introduced blockable parameter to all mmu_notifiers and the notifier
> has to back off when called in !blockable case and it could block down
> the road.
>
> The above commit implemented that for mn_invl_range_start but both
> in_range checks are done unconditionally regardless of the blockable
> mode and as such they would fail all the time for regular calls.
> Fix this by checking blockable parameter as well.
>
> Once we are there we can remove the stale TODO. The lock has to be
> sleepable because we wait for completion down in gnttab_unmap_refs_sync.
>
> Fixes: 93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Juergen Gross <jgross@suse.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracel.com>
