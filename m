Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5076B0194
	for <linux-mm@kvack.org>; Fri, 22 May 2015 10:28:27 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so49324964wic.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 07:28:27 -0700 (PDT)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id cx3si8851007wib.115.2015.05.22.07.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 07:28:26 -0700 (PDT)
Received: by wgbgq6 with SMTP id gq6so19537598wgb.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 07:28:25 -0700 (PDT)
Date: Fri, 22 May 2015 16:28:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Message-ID: <20150522142824.GG5109@dhcp22.suse.cz>
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
 <20150521170909.GA12800@cmpxchg.org>
 <20150522142143.GF5109@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522142143.GF5109@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 22-05-15 16:21:43, Michal Hocko wrote:
> On Thu 21-05-15 13:09:09, Johannes Weiner wrote:
[...]
> > This makes a lot of sense to me.  The only thing I worry about is the
> > proliferation of PageHuge(), a function call, in relatively hot paths.
> 
> I've tried that (see the patch below) but it enlarged the code by almost
> 1k
>    text    data     bss     dec     hex filename
>  510323   74273   44440  629036   9992c mm/built-in.o.before
>  511248   74273   44440  629961   99cc9 mm/built-in.o.after
> 
> I am not sure the code size increase is worth it. Maybe we can reduce
> the check to only PageCompound(page) as huge pages are no in the page
> cache (yet).

Just to prevent from confusion. I means to reduce the check only for
this particular case. But that is probably not worth the troubles
either...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
