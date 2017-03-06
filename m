Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3339F6B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:38:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so66112818wrc.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:38:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6si14648069wmd.124.2017.03.06.05.38.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 05:38:38 -0800 (PST)
Date: Mon, 6 Mar 2017 14:38:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: use is_migrate_highatomic() to simplify the code
Message-ID: <20170306133832.GE27953@dhcp22.suse.cz>
References: <58B94F15.6060606@huawei.com>
 <20170303131808.GH31499@dhcp22.suse.cz>
 <20170303150619.4011826c7e645c0725efd6ae@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303150619.4011826c7e645c0725efd6ae@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 03-03-17 15:06:19, Andrew Morton wrote:
> On Fri, 3 Mar 2017 14:18:08 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 03-03-17 19:10:13, Xishi Qiu wrote:
> > > Introduce two helpers, is_migrate_highatomic() and is_migrate_highatomic_page().
> > > Simplify the code, no functional changes.
> > 
> > static inline helpers would be nicer than macros
> 
> Always.
> 
> We made a big dependency mess in mmzone.h.  internal.h works.

Just too bad we have three different header files for
is_migrate_isolate{_page} - include/linux/page-isolation.h
is_migrate_cma{_page} - include/linux/mmzone.h
is_migrate_highatomic{_page} - mm/internal.h

I guess we want all of them in internal.h?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
