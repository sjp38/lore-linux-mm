Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC0B46B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 09:44:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 139so2653222wmf.5
        for <linux-mm@kvack.org>; Wed, 17 May 2017 06:44:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si2387045edf.207.2017.05.17.06.44.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 06:44:16 -0700 (PDT)
Date: Wed, 17 May 2017 15:44:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Qustion] vmalloc area overlap with another allocated vmalloc
 area
Message-ID: <20170517134412.GL18247@dhcp22.suse.cz>
References: <591A8814.1010503@huawei.com>
 <591C47E5.9010806@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <591C47E5.9010806@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 17-05-17 20:53:57, zhong jiang wrote:
> +to linux-mm maintainer for any suggestions
> 
> Thanks
> zhongjiang
> On 2017/5/16 13:03, zhong jiang wrote:
> > Hi
> >
> > I  hit the following issue by runing /proc/vmallocinfo.  The kernel is 4.1 stable and
> > 32 bit to be used.  after I expand the vamlloc area,  the issue is not occur again.
> > it is related to the overflow. but I do not see any problem so far.

Is this a clean 4.1 stable kernel without any additional patches on top?
Are you able to reproduce this? How? Does the same problem happen with
the current Linus tree?

> > cat /proc/vmallocinfo
> > 0xf1580000-0xf1600000  524288 raw_dump_mem_write+0x10c/0x188 phys=8b901000 ioremap
> > 0xf1638000-0xf163a000    8192 mcss_pou_queue_init+0xa0/0x13c [mcss] phys=fc614000 ioremap
> > 0xf528e000-0xf5292000   16384 n_tty_open+0x10/0xd0 pages=3 vmalloc
> > 0xf5000000-0xf9001000 67112960 devm_ioremap+0x38/0x70 phys=40000000 ioremap
> > 0xfe001000-0xfe002000    4096 iotable_init+0x0/0xc phys=20001000 ioremap
> > 0xfe200000-0xfe201000    4096 iotable_init+0x0/0xc phys=1a000000 ioremap
> > 0xff100000-0xff101000    4096 iotable_init+0x0/0xc phys=2000a000 ioremap
> >
> > n_tty_open allocate the vmap area is surrounded by the devm_ioremap ioremap by above info.
> > I do not see also the race in the condition.
> >
> > I have no idea to the issue.  Anyone has any suggestions will be appreicated.
> > The related config is attatched.
> >
> > Thanks
> > zhongjiang
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
