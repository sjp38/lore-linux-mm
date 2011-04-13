Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 897BE900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:56:29 -0400 (EDT)
Received: by vws4 with SMTP id 4so1095786vws.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:56:25 -0700 (PDT)
Date: Thu, 14 Apr 2011 03:56:18 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: percpu: preemptless __per_cpu_counter_add
Message-ID: <20110413185618.GA3987@mtj.dyndns.org>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>
 <alpine.DEB.2.00.1104131148070.20908@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104131148070.20908@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, eric.dumazet@gmail.com

On Wed, Apr 13, 2011 at 11:49:51AM -0500, Christoph Lameter wrote:
> Duh the retry setup if the number overflows is not correct.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Can you please repost folded patch with proper [PATCH] subject line
and cc shaohua.li@intel.com so that he can resolve conflicts?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
