Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 12F046B0256
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:07:11 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id c200so35573764wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 08:07:11 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id h197si4795352wmd.118.2016.02.25.08.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 08:07:09 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 760341C1A84
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 16:07:09 +0000 (GMT)
Date: Thu, 25 Feb 2016 16:07:07 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
Message-ID: <20160225160707.GX2854@techsingularity.net>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn>
 <20160225092752.GU2854@techsingularity.net>
 <56CF1202.2020809@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <56CF1202.2020809@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Thu, Feb 25, 2016 at 10:38:58PM +0800, Chen Gang wrote:
> On 2/25/16 17:27, Mel Gorman wrote:
> > On Thu, Feb 25, 2016 at 06:26:31AM +0800, chengang@emindsoft.com.cn wrote:
> >> From: Chen Gang <chengang@emindsoft.com.cn>
> >>
> >> Always notice about 80 columns, and the white space near '|'.
> >>
> >> Let the wrapped function parameters align as the same styles.
> >>
> >> Remove redundant statement "enum zone_type z;" in function gfp_zone.
> >>
> >> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> > 
> > NAK from me at least. From my perspective, it's preferrable to preserve
> > blame than go through a layer of cleanup when looking for the commit
> > that defined particular flags. It's ok to cleanup code at the same time
> > definitions change for functional or performance reasons.
> > 
> 
> I can understand for your NAK, it is a trivial patch. For me, I guess
> trivial@kernel.org will care about this kind of patch.
> 

I do not want this patch to go through the trivial tree. It still adds
another step to identifying relevant commits through git blame and has
limited, if any, benefit to maintainability.

>   "it's preferable to preserve blame than go through a layer of cleanup
>   when looking for the commit that defined particular flags".
> 

git blame identifies what commit last altered a line. If a cleanup patch
is encountered then the tree before that commit needs to be examined
which adds time. It's rare that cleanup patches on their own are useful
and this is one of those cases.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
