Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 665BF6B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 15:43:20 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 67so210293304pfg.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:43:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m17si1874097pfi.261.2017.03.06.12.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 12:43:19 -0800 (PST)
Date: Mon, 6 Mar 2017 12:43:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: use is_migrate_highatomic() to simplify the
 code
Message-Id: <20170306124318.e88843a07c76584bee7689e2@linux-foundation.org>
In-Reply-To: <20170306133832.GE27953@dhcp22.suse.cz>
References: <58B94F15.6060606@huawei.com>
	<20170303131808.GH31499@dhcp22.suse.cz>
	<20170303150619.4011826c7e645c0725efd6ae@linux-foundation.org>
	<20170306133832.GE27953@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 6 Mar 2017 14:38:33 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 03-03-17 15:06:19, Andrew Morton wrote:
> > On Fri, 3 Mar 2017 14:18:08 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > On Fri 03-03-17 19:10:13, Xishi Qiu wrote:
> > > > Introduce two helpers, is_migrate_highatomic() and is_migrate_highatomic_page().
> > > > Simplify the code, no functional changes.
> > > 
> > > static inline helpers would be nicer than macros
> > 
> > Always.
> > 
> > We made a big dependency mess in mmzone.h.  internal.h works.
> 
> Just too bad we have three different header files for
> is_migrate_isolate{_page} - include/linux/page-isolation.h
> is_migrate_cma{_page} - include/linux/mmzone.h
> is_migrate_highatomic{_page} - mm/internal.h
> 
> I guess we want all of them in internal.h?

I suppose so.  arch/powerpc/mm/mmu_context_iommu.c is using
is_migrate_cma_page which would need some attention.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
