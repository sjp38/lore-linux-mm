Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 3BC306B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 22:30:29 -0400 (EDT)
Message-ID: <4F9DF93F.30403@kernel.org>
Date: Mon, 30 Apr 2012 11:30:23 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix devision by 0 in percpu_pagelist_fraction
References: <1335623131-15728-1-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1335623131-15728-1-git-send-email-levinsasha928@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: akpm@linux-foundation.org, rohit.seth@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/28/2012 11:25 PM, Sasha Levin wrote:

> percpu_pagelist_fraction_sysctl_handler() has only considered -EINVAL as a possible error
> from proc_dointvec_minmax(). If any other error is returned, it would proceed to divide by
> zero since percpu_pagelist_fraction wasn't getting initialized at any point. For example,
> writing 0 bytes into the proc file would trigger the issue.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>


Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
