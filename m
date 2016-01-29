Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 379E26B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 03:38:01 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id ho8so38010108pac.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 00:38:01 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rr5si2164218pab.188.2016.01.29.00.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 00:38:00 -0800 (PST)
Date: Fri, 29 Jan 2016 11:37:49 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] vmpressure: Fix subtree pressure detection
Message-ID: <20160129083749.GB4952@esperanza>
References: <1453912137-25473-1-git-send-email-vdavydov@virtuozzo.com>
 <20160128155531.GE15948@dhcp22.suse.cz>
 <56AA6AEE.30004@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <56AA6AEE.30004@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 28, 2016 at 08:24:30PM +0100, Vlastimil Babka wrote:
> On 28.1.2016 16:55, Michal Hocko wrote:
> > On Wed 27-01-16 19:28:57, Vladimir Davydov wrote:
> >> When vmpressure is called for the entire subtree under pressure we
> >> mistakenly use vmpressure->scanned instead of vmpressure->tree_scanned
> >> when checking if vmpressure work is to be scheduled. This results in
> >> suppressing all vmpressure events in the legacy cgroup hierarchy. Fix
> >> it.
> >>
> >> Fixes: 8e8ae645249b ("mm: memcontrol: hook up vmpressure to socket pressure")
> >> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > 
> > a = b += c made me scratch my head for a second but this looks correct
> 
> Ugh, it's actually a = b += a
> 
> While clever and compact, this will make scratch their head anyone looking at
> the code in the future. Is it worth it?

I'm just trying to be consistend with the !tree case, where we do
exactly the same.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
