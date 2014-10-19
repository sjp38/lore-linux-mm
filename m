Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id D50716B0069
	for <linux-mm@kvack.org>; Sun, 19 Oct 2014 08:31:58 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id gm9so2667762lab.27
        for <linux-mm@kvack.org>; Sun, 19 Oct 2014 05:31:58 -0700 (PDT)
Received: from smtp1.it.da.ut.ee (mailhost6-1.ut.ee. [2001:bb8:2002:500::46])
        by mx.google.com with ESMTP id n7si9990666laj.61.2014.10.19.05.31.56
        for <linux-mm@kvack.org>;
        Sun, 19 Oct 2014 05:31:57 -0700 (PDT)
Date: Sun, 19 Oct 2014 15:31:56 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <20141018.142335.1935310766779155342.davem@davemloft.net>
Message-ID: <alpine.LRH.2.11.1410191459210.32417@adalberg.ut.ee>
References: <20141016.165017.1151349565275102498.davem@davemloft.net> <alpine.LRH.2.11.1410171410210.25429@adalberg.ut.ee> <20141018.135907.356113264227709132.davem@davemloft.net> <20141018.142335.1935310766779155342.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> > I don't want to define the array size of the fpregs save area
> > explicitly and thereby placing an artificial limit there.
> 
> Nevermind, it seems we have a hard limit of 7 FPU save areas anyways.
> 
> Meelis, please try this patch:

Works fine with 3.17.0-09670-g0429fbc + fault patch.

Will try current git next to find any new problems :)

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
