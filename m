Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id B1F896B006E
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 14:06:42 -0500 (EST)
Received: by wibhm9 with SMTP id hm9so9888831wib.2
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 11:06:42 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id jd11si31187804wic.14.2015.03.04.11.06.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 11:06:41 -0800 (PST)
Date: Wed, 4 Mar 2015 14:06:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: make CONFIG_MEMCG depend on CONFIG_MMU
Message-ID: <20150304190635.GC21350@phnom.home.cmpxchg.org>
References: <1425492428-27562-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425492428-27562-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chen Gang <762976180@qq.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 04, 2015 at 07:07:08PM +0100, Michal Hocko wrote:
> CONFIG_MEMCG might be currently enabled also for !MMU architectures
> which was probably an omission because Balbir had this on the TODO
> list section (https://lkml.org/lkml/2008/3/16/59)
> "
> Only when CONFIG_MMU is enabled, is the virtual address space control
> enabled. Should we do this for nommu cases as well? My suspicion is
> that we don't have to.
> "
> I do not see any traces for !MMU requests after then. The code compiles
> with !MMU but I haven't heard about anybody using it in the real life
> so it is not clear to me whether it works and it is usable at all
> considering how !MMU configuration is restricted.
> 
> Let's make CONFIG_MEMCG depend on CONFIG_MMU to make our support
> explicit and also to get rid of few ifdefs in the code base.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Sorry about the misunderstanding, I actually acked Chen's patch.  As I
said, there is nothing inherent in memcg that would prevent using it
on NOMMU systems except for this charges-follow-tasks feature, so I'd
rather fix the compiler warning than adding this dependency.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
