Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 74A6D6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 03:34:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w11so22849790wrc.2
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 00:34:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si9892281wmf.50.2017.04.03.00.34.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 00:34:18 -0700 (PDT)
Date: Mon, 3 Apr 2017 09:34:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170403073413.GD24661@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170331191924.GB3021@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170331191924.GB3021@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Fri 31-03-17 21:19:24, Heiko Carstens wrote:
> On Thu, Mar 30, 2017 at 01:54:48PM +0200, Michal Hocko wrote:
> > Patch 5 is the core of the change. In order to make it easier to review
> > I have tried it to be as minimalistic as possible and the large code
> > removal is moved to patch 6.
> > 
> > I would appreciate if s390 folks could take a look at patch 4 and the
> > arch_add_memory because I am not sure I've grokked what they wanted to
> > achieve there completely.
> 
> [adding Gerald Schaefer]
> 
> This seems to work fine on s390. So for the s390 bits:
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Thanks a lot!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
