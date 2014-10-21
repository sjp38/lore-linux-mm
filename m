Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id EEC226B0081
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 12:23:50 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id r20so2419994wiv.2
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 09:23:50 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id n6si15326174wjx.83.2014.10.21.09.23.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 09:23:47 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id fb4so2398319wid.4
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 09:23:47 -0700 (PDT)
Date: Tue, 21 Oct 2014 18:23:40 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141021162340.GA5508@gmail.com>
References: <20141020215633.717315139@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141020215633.717315139@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Peter Zijlstra <peterz@infradead.org> wrote:

> My Ivy Bridge EP (2*10*2) has a ~58% improvement in pagefault throughput:
> 
> PRE:
>        149,441,555      page-faults                  ( +-  1.25% )
>
> POST:
>        236,442,626      page-faults                  ( +-  0.08% )

> My Ivy Bridge EX (4*15*2) has a ~78% improvement in pagefault throughput:
> 
> PRE:
>        105,789,078      page-faults                 ( +-  2.24% )
>
> POST:
>        187,751,767      page-faults                 ( +-  2.24% )

I guess the 'PRE' and 'POST' numbers should be flipped around?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
