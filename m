Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 720546B02C3
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 09:54:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z81so45656744wrc.2
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 06:54:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o23si13404602wro.277.2017.07.04.06.54.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 06:54:34 -0700 (PDT)
Date: Tue, 4 Jul 2017 15:54:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?UmXvvJpbUEFUQ0g=?= =?utf-8?Q?=5D?= mm: vmpressure:
 simplify pressure ratio calculation
Message-ID: <20170704135431.GS14722@dhcp22.suse.cz>
References: <91b685c4-acee-4ecd-9176-ab95a7172cac.zbestahu@aliyun.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91b685c4-acee-4ecd-9176-ab95a7172cac.zbestahu@aliyun.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zbestahu <zbestahu@aliyun.com>
Cc: akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, Yue Hu <huyue2@coolpad.com>, Anton Vorontsov <anton.vorontsov@linaro.org>

On Tue 04-07-17 21:43:39, zbestahu wrote:
> Michal wrote:
> > > the existing percent
> > > calculation using scale should be about rounding to intege, it
> > > seems to be redundant, we can calculate it directly just like
> > > "pressure = not_relaimed * 100 / scanned", no rounding issue. And
> > > it's also better because of saving several arithmetic operations.
> 
> > and you haven't explained why that change is so much better to change
> > the behavior.
> 
> it removes 3 below arithmetic instructions so it should be running faster.
> add: scanned + reclaimed
> mul: scale * reclaimed
> udiv: reclaimed * scale /scanned

That part is clear from the diff... What is not clear from the diff is
your motivation. This path is not hot (we are in the reclaim which is a
slow path) and few extra instructions are acceptable. Sure we can
optimize it if the resulting code is working as expected. What I am
asking (obviously unsuccessfully) is to describe _why_ it is better.
This is a requirement for _each patch_. We are not changing the code
"just because I like it more that way".
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
