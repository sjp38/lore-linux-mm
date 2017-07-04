Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8AA6B0292
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 09:13:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 4so45593997wrc.15
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 06:13:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a3si12960563wmc.142.2017.07.04.06.13.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 06:13:47 -0700 (PDT)
Date: Tue, 4 Jul 2017 15:13:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?5Zue5aSN77yaW1BBVENI?= =?utf-8?Q?=5D?= mm: vmpressure:
 simplify pressure ratio calculation
Message-ID: <20170704131345.GR14722@dhcp22.suse.cz>
References: <b7riv0v73isdtxyi4coi6g7b.1499072995215@email.android.com>
 <00146e00-d941-4311-8494-3e4220b04103.zbestahu@aliyun.com>
 <2da6833d-4c6b-4df0-9dd3-ff8ce605865f.zbestahu@aliyun.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2da6833d-4c6b-4df0-9dd3-ff8ce605865f.zbestahu@aliyun.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zbestahu <zbestahu@aliyun.com>
Cc: akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, Yue Hu <huyue2@coolpad.com>, Anton Vorontsov <anton.vorontsov@linaro.org>

On Tue 04-07-17 21:08:15, zbestahu wrote:
> Michal wrote: 
> > Make sure you describe all that in the changelog because your original
> > patch description wasn't all that clear about your intention.
> 
> The patch's description is updated as following:
> 
> The patch does not change the function,

yes it pretty much changes the result.

> the existing percent
> calculation using scale should be about rounding to intege, it
> seems to be redundant, we can calculate it directly just like
> "pressure = not_relaimed * 100 / scanned", no rounding issue. And
> it's also better because of saving several arithmetic operations.

and you haven't explained why that change is so much better to change
the behavior.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
