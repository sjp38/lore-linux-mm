Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9360B6B0259
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 05:00:30 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so8454060wic.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 02:00:30 -0700 (PDT)
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id ba10si1803321wib.29.2015.07.14.02.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 02:00:28 -0700 (PDT)
Received: by wgxm20 with SMTP id m20so3171772wgx.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 02:00:27 -0700 (PDT)
Date: Tue, 14 Jul 2015 11:00:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [BUG REPORT] OOM Killer is invoked while the system still has
 much memory
Message-ID: <20150714090025.GA17660@dhcp22.suse.cz>
References: <6D317A699782EA4DB9A0E6266C9219696CA2B3BC@SZXEMA501-MBX.china.huawei.com>
 <20150714081521.GA17711@dhcp22.suse.cz>
 <55A4CB68.5060906@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55A4CB68.5060906@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Xuzhichuang <xuzhichuang@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Songjiangtao (mygirlsjt)" <songjiangtao.song@huawei.com>, "Zhangwei (FF)" <zw.zhang@huawei.com>

On Tue 14-07-15 16:42:16, Xishi Qiu wrote:
> On 2015/7/14 16:15, Michal Hocko wrote:
> 
> > On Tue 14-07-15 07:11:34, Xuzhichuang wrote:
[...]
> >> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138968] DMA32: 188513*4kB 29459*8kB 2*16kB 2*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 990396kB
> > 
> > Moreover your allocation request was oreder 2 and you do not have much
> > memory there because most of the free memory is in order-0-2.
> > 
> 
> Hi Michal,
> 
> order=2 -> alloc 16kb memory, and DMA32 still has 2*16kB 2*32kB 1*64kB 1*512kB, 
> so you mean this large buddy block was reclaimed during the moment of oom and 
> print, right?

Not really. Those high order blocks are inaccessible for your GFP_KERNEL
allocation. See __zone_watermark_ok.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
