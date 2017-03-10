Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C439280903
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 19:45:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o126so139482164pfb.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 16:45:25 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z21si1246450pgc.419.2017.03.09.16.45.23
        for <linux-mm@kvack.org>;
        Thu, 09 Mar 2017 16:45:24 -0800 (PST)
Date: Fri, 10 Mar 2017 09:45:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: "mm: fix lazyfree BUG_ON check in try_to_unmap_one()" build error
Message-ID: <20170310004522.GA12267@bbox>
References: <20170309042908.GA26702@jagdpanzerIV.localdomain>
 <20170309060226.GB854@bbox>
 <20170309132706.1cb4fc7d2e846923eedf788c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309132706.1cb4fc7d2e846923eedf788c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andrew,

On Thu, Mar 09, 2017 at 01:27:06PM -0800, Andrew Morton wrote:
> On Thu, 9 Mar 2017 15:02:26 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Sergey reported VM_WARN_ON_ONCE returns void with !CONFIG_DEBUG_VM
> > so we cannot use it as if's condition unlike WARN_ON.
> 
> Can we instead fix VM_WARN_ON_ONCE()?

I thought the direction but the reason to decide WARN_ON_ONCE in this case
is losing of benefit with using CONFIG_DEBU_VM if we go that way.

I think the benefit with VM_WARN_ON friends is that it should be completely
out from the binary in !CONFIG_DEBUG_VM. However, if we fix VM_WARN_ON
like WARN_ON to !!condition, at least, compiler should generate condition
check and return so it's not what CONFIG_DEBUG_VM want, IMHO.
However, if guys believe it's okay to add some instructions to debug VM
although we disable CONFIG_DEBUG_VM, we can go that way.
It's a just policy matter. ;-)

Anyway, Even though we fix VM_WARN_ON_ONCE, in my case, WARN_ON_ONCE is
better because we should do !!condition regardless of CONFIG_DEBUG_VM
and if so, WARN_ON is more wide coverage than VM_WARN_ON which only works
with CONFIG_DEBUG_VM.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
