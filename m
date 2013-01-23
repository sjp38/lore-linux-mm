Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8F7216B0005
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 01:19:59 -0500 (EST)
Date: Wed, 23 Jan 2013 15:19:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Build error of mmotm-2013-01-18-15-48
Message-ID: <20130123061957.GG2723@blaptop>
References: <20130123041101.GC2723@blaptop>
 <50FF75D1.6070303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FF75D1.6070303@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: linux-mm@kvack.org

On Wed, Jan 23, 2013 at 01:32:01PM +0800, Tang Chen wrote:
> On 01/23/2013 12:11 PM, Minchan Kim wrote:
> >Hi Tang Chen,
> >
> >I encountered build error from mmotm-2013-01-18-15-48 when I try to
> >build ARM config. I know you sent a bunch of patches but not sure
> >it was fixed via them.
> >
> >Thanks.
> >
> >   CHK     include/generated/uapi/linux/version.h
> >   CHK     include/generated/utsrelease.h
> >make[1]: `include/generated/mach-types.h' is up to date.
> >   CALL    scripts/checksyscalls.sh
> >   CC      mm/memblock.o
> >mm/memblock.c: In function 'memblock_find_in_range_node':
> >mm/memblock.c:104: error: invalid use of undefined type 'struct movablecore_map'
> >mm/memblock.c:123: error: invalid use of undefined type 'struct movablecore_map'
> >mm/memblock.c:130: error: invalid use of undefined type 'struct movablecore_map'
> >mm/memblock.c:131: error: invalid use of undefined type 'struct movablecore_map'
> >
> 
> Hi Minchan,
> 
> Thank you for reporting this. :)
> 
> I think this problem has been fixed by the following patch I sent yesterday.
> But it is weird, I cannot access to the LKML site of 2013/1/22. So I didn't
> get an url for you. :)
> 
> This patch was merged into -mm tree this morning.
> 
> And since I don't have an ARM platform, so I didn't test it on ARM.
> Please tell me if your problem is not solved after applying this patch.
> 
> Thanks. :)

Fixed. Thanks for quick response!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
