Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4DED76B0036
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 21:33:49 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb12so1602196pbc.36
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 18:33:48 -0700 (PDT)
Message-ID: <525F3E39.3060603@asianux.com>
Date: Thu, 17 Oct 2013 09:32:41 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/readahead.c: need always return 0 when system call
 readahead() succeeds
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org> <52390907.7050101@asianux.com> <525CF787.6050107@asianux.com> <alpine.DEB.2.02.1310161603280.2417@chino.kir.corp.google.com> <525F35F7.4070202@asianux.com> <alpine.DEB.2.02.1310161812480.12062@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1310161812480.12062@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On 10/17/2013 09:17 AM, David Rientjes wrote:
> On Thu, 17 Oct 2013, Chen Gang wrote:
> 
>> If possible, you can help me check all my patches again (at least, it is
>> not a bad idea to me).  ;-)
>>
> 
> I think your patches should be acked before being merged into linux-next, 
> Hugh just had to revert another one that did affect Linus's tree in 
> 1ecfd533f4c5 ("mm/mremap.c: call pud_free() after fail calling
> pmd_alloc()").  I had to revert your entire series of mpol_to_str() 
> changes in -mm.  It's getting ridiculous and a waste of other people's 
> time.
> 

If always get no reply, what to do, next?

In fact, in the whole kernel wide, at least, I have almost 10 patches
pending at least 2-3 weeks which got no reply (neither say ack, nor
nack), is it necessary to list them in this mail thread. ;-)

But all together, I welcome you to help ack/nack my patches for mm
sub-system (although I don't know your ack/nack whether have effect or not).

:-)

>>> Nack to this and nack to the problem patch, which is absolutely pointless 
>>> and did nothing but introduce this error.  readahead() is supposed to 
>>> return 0, -EINVAL, or -EBADF and your original patch broke it.  That's 
>>> because your original patch was completely pointless to begin with.
>>>
>>
>> Do you mean: in do_readahead(), we need not check the return value of
>> force_page_cache_readahead()?
>>
> 
> I'm saying we should revert 
> mm-readaheadc-return-the-value-which-force_page_cache_readahead-returns.patch 
> which violates the API of a syscall.  I see that patch has since been 
> removed from -mm, so I'm happy with the result.
> 
> 

Excuse me, I am not quite familiar with the upstream kernel version
trees merging.

Hmm... I think the final result need be: "still need check the return
value of force_patch_cache_readahead(), but need return 0 in readahead()
and madvise_willneed()".

Do you also think so, or do you happy with this result?


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
