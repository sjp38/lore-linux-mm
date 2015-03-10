Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id D21F06B0092
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 16:20:07 -0400 (EDT)
Received: by lbiw7 with SMTP id w7so4415480lbi.6
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 13:20:07 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id m5si962180laj.177.2015.03.10.13.20.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 13:20:05 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1YVQdH-0002ea-Ep
	for linux-mm@kvack.org; Tue, 10 Mar 2015 21:20:03 +0100
Received: from 204.14.239.74 ([204.14.239.74])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:20:03 +0100
Received: from atomiclong64 by 204.14.239.74 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:20:03 +0100
From: Lock Free <atomiclong64@gmail.com>
Subject: Re: Greedy kswapd reclaim behavior
Date: Tue, 10 Mar 2015 20:18:20 +0000 (UTC)
Message-ID: <loom.20150310T211234-554@post.gmane.org>
References: <CAN3bvwucTo41Kk+NdUf8Fa_bkVWyeMcRo2ttAJeDM0G9bHjLiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I should also clarify the true min/low/high watermark thresholds.

min watermark is 11275 * 4096 = 44MB
low watermark is 14093 * 4096 = 55MB
high watermark is 16912 * 4096 = 66MB

Is it expected that kswapd reclaims significantly more pages than the high 
watermark?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
