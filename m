Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7056B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 11:26:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f193so1160029wmg.3
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 08:26:20 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id k88si289442wmh.15.2016.10.14.08.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 08:26:18 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id c78so580663wme.1
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 08:26:18 -0700 (PDT)
Date: Fri, 14 Oct 2016 17:26:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: some question about order0 page allocation
Message-ID: <20161014152615.GB6105@dhcp22.suse.cz>
References: <CADUS3okBoQNW_mzgZnfr6evK2Qrx2TDtPygqnodn0CwtSyrA8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADUS3okBoQNW_mzgZnfr6evK2Qrx2TDtPygqnodn0CwtSyrA8w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yoma sophian <sophian.yoma@gmail.com>
Cc: linux-mm@kvack.org

On Fri 14-10-16 17:29:34, yoma sophian wrote:
[...]
> [ 5515.127555] dialog invoked oom-killer: gfp_mask=0x80d0, order=0,
> oom_score_adj=0

This looks like a GFP_KERNEL + something allocation

> [ 5515.444859] Normal: 4314*4kB (UEMC) 3586*8kB (UMC) 131*16kB (MC)
> 21*32kB (C) 6*64kB (C) 1*128kB (C) 0*256kB 0*512kB 0*1024kB 0*2048kB
> 0*4096kB = 49224kB

And it seems like CMA blocks are spread in all orders and no unmovable
allocations can fallback in them. It seems that there should be some
movable blocks but I do not have any idea why those are not used. Anyway
this is where I would start investigating.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
