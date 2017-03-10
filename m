Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6990F2808F6
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 04:31:28 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id g10so26745198wrg.5
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 01:31:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s10si12168110wrb.43.2017.03.10.01.31.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 01:31:26 -0800 (PST)
Subject: Re: "mm: fix lazyfree BUG_ON check in try_to_unmap_one()" build error
References: <20170309042908.GA26702@jagdpanzerIV.localdomain>
 <20170309060226.GB854@bbox>
 <20170309132706.1cb4fc7d2e846923eedf788c@linux-foundation.org>
 <20170310004522.GA12267@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8e17c4e0-eb64-9910-1406-208e0fb3dd31@suse.cz>
Date: Fri, 10 Mar 2017 10:31:25 +0100
MIME-Version: 1.0
In-Reply-To: <20170310004522.GA12267@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/10/2017 01:45 AM, Minchan Kim wrote:
> Hi Andrew,
> 
> On Thu, Mar 09, 2017 at 01:27:06PM -0800, Andrew Morton wrote:
>> On Thu, 9 Mar 2017 15:02:26 +0900 Minchan Kim <minchan@kernel.org> wrote:
>>
>>> Sergey reported VM_WARN_ON_ONCE returns void with !CONFIG_DEBUG_VM
>>> so we cannot use it as if's condition unlike WARN_ON.
>>
>> Can we instead fix VM_WARN_ON_ONCE()?
> 
> I thought the direction but the reason to decide WARN_ON_ONCE in this case
> is losing of benefit with using CONFIG_DEBU_VM if we go that way.
> 
> I think the benefit with VM_WARN_ON friends is that it should be completely
> out from the binary in !CONFIG_DEBUG_VM. However, if we fix VM_WARN_ON
> like WARN_ON to !!condition, at least, compiler should generate condition
> check and return so it's not what CONFIG_DEBUG_VM want, IMHO.
> However, if guys believe it's okay to add some instructions to debug VM
> although we disable CONFIG_DEBUG_VM, we can go that way.
> It's a just policy matter. ;-)
> 
> Anyway, Even though we fix VM_WARN_ON_ONCE, in my case, WARN_ON_ONCE is
> better because we should do !!condition regardless of CONFIG_DEBUG_VM
> and if so, WARN_ON is more wide coverage than VM_WARN_ON which only works
> with CONFIG_DEBUG_VM.

Agreed. WARN_ON...() can work that way as one can't disable them
(AFAIK), but VM_* variants are optional for overhead reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
