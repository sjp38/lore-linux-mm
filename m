Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3CACA6B0265
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:48:04 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fn2so40065263pad.7
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:48:04 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r195si5272617pgr.210.2016.10.12.03.48.03
        for <linux-mm@kvack.org>;
        Wed, 12 Oct 2016 03:48:03 -0700 (PDT)
Date: Wed, 12 Oct 2016 11:47:58 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Ensure that the task stack is not freed
 during scanning
Message-ID: <20161012104758.GB21592@e104818-lin.cambridge.arm.com>
References: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
 <00ca01d22471$bcef4ef0$36cdecd0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00ca01d22471$bcef4ef0$36cdecd0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Andy Lutomirski' <luto@kernel.org>, 'CAI Qian' <caiqian@redhat.com>

On Wed, Oct 12, 2016 at 06:16:46PM +0800, Hillf Danton wrote:
> > @@ -1453,8 +1453,11 @@ static void kmemleak_scan(void)
> > 
> >  		read_lock(&tasklist_lock);
> >  		do_each_thread(g, p) {
> 
> Take a look at this commit please.
> 	1da4db0cd5 ("oom_kill: change oom_kill.c to use for_each_thread()")

Thanks. Isn't holding tasklist_lock here enough to avoid such races?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
