Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0FB6B0044
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 23:28:00 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so2047577wes.8
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 20:28:00 -0700 (PDT)
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
        by mx.google.com with ESMTPS id hk8si6136wib.13.2014.06.12.20.27.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 20:27:58 -0700 (PDT)
Received: by mail-we0-f170.google.com with SMTP id w61so2166323wes.29
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 20:27:58 -0700 (PDT)
Date: Fri, 13 Jun 2014 06:27:54 +0300
From: Dan Aloni <dan@kernelim.com>
Subject: Re: mm/sched/net: BUG when running simple code
Message-ID: <20140613032754.GA20729@gmail.com>
References: <539A6850.4090408@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539A6850.4090408@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Thu, Jun 12, 2014 at 10:56:16PM -0400, Sasha Levin wrote:
> Hi all,
> 
> Okay, I'm really lost. I got the following when fuzzing, and can't really explain what's
> going on. It seems that we get a "unable to handle kernel paging request" when running
> rather simple code, and I can't figure out how it would cause it.
[..]
> Which agrees with the trace I got:
> 
> [  516.309720] BUG: unable to handle kernel paging request at ffffffffa0f12560
> [  516.309720] IP: netlink_getsockopt (net/netlink/af_netlink.c:2271)
[..]
> [  516.309720] RIP netlink_getsockopt (net/netlink/af_netlink.c:2271)
> [  516.309720]  RSP <ffff8803fc85fed8>
> [  516.309720] CR2: ffffffffa0f12560
> 
> They only theory I had so far is that netlink is a module, and has gone away while the code
> was executing, but netlink isn't a module on my kernel.

The RIP - 0xffffffffa0f12560 is in the range (from Documentation/x86/x86_64/mm.txt):

    ffffffffa0000000 - ffffffffff5fffff (=1525 MB) module mapping space

So seems it was in a module.

-- 
Dan Aloni

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
