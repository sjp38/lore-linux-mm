Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9996B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 08:27:21 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so5433237wml.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 05:27:21 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id k4si26903967wje.12.2016.02.28.05.27.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 28 Feb 2016 05:27:20 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 6F95B98A9F
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 13:27:19 +0000 (UTC)
Date: Sun, 28 Feb 2016 13:27:17 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
Message-ID: <20160228132717.GD2854@techsingularity.net>
References: <20160225092752.GU2854@techsingularity.net>
 <56CF1202.2020809@emindsoft.com.cn>
 <20160225160707.GX2854@techsingularity.net>
 <56CF8043.1030603@emindsoft.com.cn>
 <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com>
 <56D06E8A.9070106@emindsoft.com.cn>
 <20160227024548.GP1215@thunk.org>
 <56D1B364.8050209@emindsoft.com.cn>
 <20160227165301.GA9506@thunk.org>
 <56D23D94.50707@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <56D23D94.50707@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Theodore Ts'o <tytso@mit.edu>, Jianyu Zhan <nasa4836@gmail.com>, trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Sun, Feb 28, 2016 at 08:21:40AM +0800, Chen Gang wrote:
> 
> On 2/28/16 00:53, Theodore Ts'o wrote:
> > On Sat, Feb 27, 2016 at 10:32:04PM +0800, Chen Gang wrote:
> >> I don't think so. Of cause NOT the "CODE CHURN". It is not correct to
> >> make an early decision during discussing.
> > 
> > There is no discussion.  If the maintainer has NAK'ed it.  That's the
> > end of the dicsussion.  Period.  See:
> > 
> 
> For me, NAK also needs reasons.
> 

You already got the reasons. Not only does a patch of this type interfere
with git blame which is important even in headers but I do not think the
patch actually improves the readability of the code. For example, the
comments move to the line after the defintions which to my eye at least
looks clumsy and weird.

> I guess they are related with this patch, and their NAKs' reason are: mm
> and trivial don't care about this coding style issue, is it correct?
> 

No. Coding style is important but it's a guideline not a law. There are
cases where breaking it results in perfectly readable code. At least one
my my own recent patches was flagged by checkpatch as having style issues
but fixing the style was considerably harder to read so I left it. If the
definitions in that header need to change again in the future and there
are style issues then they can be fixed in the context of a functional
change instead of patching style just for the sake of it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
