Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 95BA26B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 10:47:14 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o70so22632511lfg.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 07:47:14 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id bx8si34861102wjc.205.2016.05.23.07.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 07:47:13 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id n129so82998009wmn.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 07:47:12 -0700 (PDT)
Date: Mon, 23 May 2016 16:47:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: page order 0 allocation fail but free pages are enough
Message-ID: <20160523144711.GV2278@dhcp22.suse.cz>
References: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yoma sophian <sophian.yoma@gmail.com>
Cc: linux-mm@kvack.org

On Mon 23-05-16 14:47:51, yoma sophian wrote:
> hi all:
> I got something wired that
> 1. in softirq, there is a page order 0 allocation request
> 2. Normal/High zone are free enough for order 0 page.
> 3. but somehow kernel return order 0 allocation fail.
> 
> My kernel version is 3.10 and below is kernel log:
> from memory info,

Can you reproduce it with the current vanlilla tree?

[...]
> [   94.586588] ksoftirqd/0: page allocation failure: order:0, mode:0x20
[...]
> [   94.865776] Normal free:63768kB min:2000kB low:2500kB high:3000kB
[...]
> [ 8606.701343] CompositorTileW: page allocation failure: order:0, mode:0x20
[...]
> [ 8606.703590] Normal free:60684kB min:2000kB low:2500kB high:3000kB

This is a lot of free memory to block GFP_ATOMIC. One possible
explanation would be that this is a race with somebody releasing a lot
of memory. The free memory is surprisingly similar in both cases.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
