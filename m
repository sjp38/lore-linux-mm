Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id B3C326B0069
	for <linux-mm@kvack.org>; Sun, 19 Oct 2014 13:12:46 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so2768596lab.20
        for <linux-mm@kvack.org>; Sun, 19 Oct 2014 10:12:45 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id a4si10969665lbm.77.2014.10.19.10.12.44
        for <linux-mm@kvack.org>;
        Sun, 19 Oct 2014 10:12:44 -0700 (PDT)
Date: Sun, 19 Oct 2014 20:12:43 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <alpine.LRH.2.11.1410191459210.32417@adalberg.ut.ee>
Message-ID: <alpine.LRH.2.11.1410192011410.32417@adalberg.ut.ee>
References: <20141016.165017.1151349565275102498.davem@davemloft.net> <alpine.LRH.2.11.1410171410210.25429@adalberg.ut.ee> <20141018.135907.356113264227709132.davem@davemloft.net> <20141018.142335.1935310766779155342.davem@davemloft.net>
 <alpine.LRH.2.11.1410191459210.32417@adalberg.ut.ee>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: iamjoonsoo.kim@lge.com, Linux Kernel list <linux-kernel@vger.kernel.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> > > I don't want to define the array size of the fpregs save area
> > > explicitly and thereby placing an artificial limit there.
> > 
> > Nevermind, it seems we have a hard limit of 7 FPU save areas anyways.
> > 
> > Meelis, please try this patch:
> 
> Works fine with 3.17.0-09670-g0429fbc + fault patch.
> 
> Will try current git next to find any new problems :)

Works on all 3 machines, with latest git (only had to apply the no-ipv6 
patch on one of them). Thank you for the good work!

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
