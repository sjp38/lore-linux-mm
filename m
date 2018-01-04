Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD4F6B04D0
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 02:33:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q186so500429pga.23
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 23:33:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4si1724219pgs.501.2018.01.03.23.33.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Jan 2018 23:33:02 -0800 (PST)
Date: Thu, 4 Jan 2018 08:32:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm, hugetlb: allocation API and migration
 improvements
Message-ID: <20180104073257.GA2801@dhcp22.suse.cz>
References: <20180103093213.26329-1-mhocko@kernel.org>
 <20180103160523.2232e3c2da1728c84b160d56@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180103160523.2232e3c2da1728c84b160d56@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 03-01-18 16:05:23, Andrew Morton wrote:
> On Wed,  3 Jan 2018 10:32:07 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > I've posted this as an RFC [1] and both Mike and Naoya seem to be OK
> > both with patches and the approach. I have rebased this on top of [2]
> > because there is a small conflict in mm/mempolicy.c. I know it is late
> > in the release cycle but similarly to [2] I would really like to see
> > this in linux-next for a longer time for a wider testing exposure.
> 
> I'm interpreting this to mean "hold for 4.17-rc1"?

Yeah, that should be good enough. There shouldn't be any reason to rush
this through. I will build more changes on top but that is not critical
either. The longer this will be in linux-next, the better.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
