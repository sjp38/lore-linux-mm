Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B118E4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 12:16:04 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id r129so222103081wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 09:16:04 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id 186si39278661wms.43.2016.02.04.09.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 09:16:03 -0800 (PST)
Received: by mail-wm0-f54.google.com with SMTP id r129so222102483wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 09:16:03 -0800 (PST)
Date: Thu, 4 Feb 2016 18:16:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2016-02-03-16-36 uploaded
Message-ID: <20160204171601.GJ14425@dhcp22.suse.cz>
References: <56b29d2d.92SImyffndn0eAz+%akpm@linux-foundation.org>
 <20160204165744.GG14425@dhcp22.suse.cz>
 <CAAmzW4OPM_+tgxxPpyb0y=qro68+MY1bio=UT+P1O_B4JKe2Yg@mail.gmail.com>
 <20160204171054.GI14425@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160204171054.GI14425@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org, Minchan Kim <minchan@kernel.org>

On Thu 04-02-16 18:10:54, Michal Hocko wrote:
> On Fri 05-02-16 02:02:08, Joonsoo Kim wrote:
> > 2016-02-05 1:57 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > > [CCing Minchan]
> > >
> > > I am getting many compilation errors if !CONFIG_COMPACTION and
> > > CONFIG_MEMORY_ISOLATION=y. I didn't get to check what has hanged in that
> > > regards because this code is quite old but the previous mmotm seemed ok,
> > > maybe some subtle change in my config?
> > 
> > It would be caused by Vlastimil's "mm, hugetlb: don't require CMA for
> > runtime gigantic pages".
> > 
> > https://lkml.org/lkml/2016/2/3/841
> > 
> > Fix is already there.
> 
> What would be the fix? Maybe I have missed it in the current mmotm...

Ohh, v2, I should have read the rest of the thread.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
