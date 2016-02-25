Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id DC4336B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 09:47:21 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so34945883wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:47:21 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id x17si10200003wju.26.2016.02.25.06.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 06:47:20 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id b205so3893674wmb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:47:20 -0800 (PST)
Date: Thu, 25 Feb 2016 15:47:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
Message-ID: <20160225144718.GD4204@dhcp22.suse.cz>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn>
 <20160225085719.GA17573@dhcp22.suse.cz>
 <56CF0E6A.2090204@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CF0E6A.2090204@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org

On Thu 25-02-16 22:23:38, Chen Gang wrote:
> On 2/25/16 16:57, Michal Hocko wrote:
> > On Thu 25-02-16 06:26:31, chengang@emindsoft.com.cn wrote:
> >>
> >> Always notice about 80 columns, and the white space near '|'.
> >>
> >> Let the wrapped function parameters align as the same styles.
> >>
> >> Remove redundant statement "enum zone_type z;" in function gfp_zone.
> > 
> > I do not think this is an improvement. The comment placement is just odd
> > and artificially splitting the mask into more lines makes git grep
> > harder to use.
> > 
> 
> Excuse me, I am not quite sure your meaning is the whole contents of the
> patch is worthless, or only for the "comment placement"?
> 
> For the "comment placement" the common way is below, but still make git
> grep harder:

if you did git grep ZONE_MOVABLE you would get less information

> 
> -#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
> +/* ZONE_MOVABLE allowed */
> +#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)
> 
> Then how about:
> 
> -#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
> +#define __GFP_MOVABLE	\
> 		((__force gfp_t)___GFP_MOVABLE) /* ZONE_MOVABLE allowed */
> 
> or:
> 
> -#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
> +#define __GFP_MOVABLE	/* ZONE_MOVABLE allowed */ \
> 			((__force gfp_t)___GFP_MOVABLE)

Now looks worse then other, really. Please try to think what would be
a benefit of such change. As Mel already pointed out git blame would
take an additional step to get back to the patch which has introduced
them. And what is the advantage? Make 80 characters-per-line rule happy?
I just do not think this is worth changes at all.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
