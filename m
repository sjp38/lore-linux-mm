Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC74F6B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:27:55 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so23422052wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:27:55 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id t5si8726106wjt.183.2016.02.25.01.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 01:27:54 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 537A91C20DC
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 09:27:54 +0000 (GMT)
Date: Thu, 25 Feb 2016 09:27:52 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
Message-ID: <20160225092752.GU2854@techsingularity.net>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chengang@emindsoft.com.cn
Cc: trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Thu, Feb 25, 2016 at 06:26:31AM +0800, chengang@emindsoft.com.cn wrote:
> From: Chen Gang <chengang@emindsoft.com.cn>
> 
> Always notice about 80 columns, and the white space near '|'.
> 
> Let the wrapped function parameters align as the same styles.
> 
> Remove redundant statement "enum zone_type z;" in function gfp_zone.
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

NAK from me at least. From my perspective, it's preferrable to preserve
blame than go through a layer of cleanup when looking for the commit
that defined particular flags. It's ok to cleanup code at the same time
definitions change for functional or performance reasons.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
