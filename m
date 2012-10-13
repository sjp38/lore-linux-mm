Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 663B76B0044
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 05:51:34 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3992543pbb.14
        for <linux-mm@kvack.org>; Sat, 13 Oct 2012 02:51:33 -0700 (PDT)
Date: Sat, 13 Oct 2012 02:51:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Q] Default SLAB allocator
In-Reply-To: <m2391ktxjj.fsf@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1210130249070.7462@chino.kir.corp.google.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com> <m27gqwtyu9.fsf@firstfloor.org> <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com> <m2391ktxjj.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Thu, 11 Oct 2012, Andi Kleen wrote:

> When did you last test? Our regressions had disappeared a few kernels
> ago.
> 

This was in August when preparing for LinuxCon, I tested netperf TCP_RR on 
two 64GB machines (one client, one server), four nodes each, with thread 
counts in multiples of the number of cores.  SLUB does a comparable job, 
but once we have the the number of threads equal to three times the number 
of cores, it degrades almost linearly.  I'll run it again next week and 
get some numbers on 3.6.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
