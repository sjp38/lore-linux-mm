Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 936896B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:45:17 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id t60so7007350wes.20
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:45:17 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id t6si7906837eeh.129.2013.12.17.22.45.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 22:45:16 -0800 (PST)
Date: Wed, 18 Dec 2013 07:45:15 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm/memory-failure.c: send action optional signal to an
 arbitrary thread
Message-ID: <20131218064515.GC20765@two.firstfloor.org>
References: <20131212222527.GD8605@mcs.anl.gov>
 <1386964742-df8sz3d6-mutt-n-horiguchi@ah.jp.nec.com>
 <20131213230004.GD7793@mcs.anl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131213230004.GD7793@mcs.anl.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamil Iskra <iskra@mcs.anl.gov>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

> I'm not sure if I understand.  "letting the main thread create a dedicated
> thread for error handling" is exactly what I was trying to do -- the
> problem is that SIGBUS(BUS_MCEERR_AO) signals are never sent to that
> thread, which is contrary to common expectations.  


Yes handling AO errors like this was the intended way 

I thought I had tested it at some point and intentionally changed the 
signal checking for this case (because normally SIGBUS cannot be
blocked). Anyways if it doesn't work it's definitely a bug.

If you fix it please make sure to add the test case to mce-test.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
