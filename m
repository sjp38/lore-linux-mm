Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCA26B006E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 08:14:40 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id b13so44379132wgh.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 05:14:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cz7si42820294wjc.17.2015.02.03.05.14.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 05:14:38 -0800 (PST)
Date: Tue, 3 Feb 2015 14:14:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/swapfile.c: use spin_lock_bh with swap_lock to avoid
 deadlocks
Message-ID: <20150203131437.GA8914@dhcp22.suse.cz>
References: <1422894328-23051-1-git-send-email-pasi.sjoholm@jolla.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1422894328-23051-1-git-send-email-pasi.sjoholm@jolla.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasi.sjoholm@jolla.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pasi =?iso-8859-1?Q?Sj=F6holm?= <pasi.sjoholm@jollamobile.com>

On Mon 02-02-15 18:25:28, pasi.sjoholm@jolla.com wrote:
> From: Pasi Sjoholm <pasi.sjoholm@jollamobile.com>
> 
> It is possible to get kernel in deadlock-state if swap_lock is not locked
> with spin_lock_bh by calling si_swapinfo() simultaneously through
> timer_function and registered vm shinker callback-function.
> 
> BUG: spinlock recursion on CPU#0, main/2447
> lock: swap_lock+0x0/0x10, .magic: dead4ead, .owner: main/2447, .owner_cpu: 0
> [<c010b938>] (unwind_backtrace+0x0/0x11c) from [<c03e9be0>] (do_raw_spin_lock+0x48/0x154)
> [<c03e9be0>] (do_raw_spin_lock+0x48/0x154) from [<c0226e10>] (si_swapinfo+0x10/0x90)
> [<c0226e10>] (si_swapinfo+0x10/0x90) from [<c04d7e18>] (timer_function+0x24/0x258)

Who is calling si_swapinfo from timer_function? AFAICS the vanilla
kernel doesn't do that. Or am I missing something?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
