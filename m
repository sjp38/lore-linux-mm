Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B52426B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:23:29 -0400 (EDT)
Message-ID: <49C8FDD4.7070900@wpkg.org>
Date: Tue, 24 Mar 2009 16:35:48 +0100
From: Tomasz Chmielewski <mangoo@wpkg.org>
MIME-Version: 1.0
Subject: Re: why my systems never cache more than ~900 MB?
References: <49C89CE0.2090103@wpkg.org> <200903250220.45575.nickpiggin@yahoo.com.au>
In-Reply-To: <200903250220.45575.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin schrieb:
> On Tuesday 24 March 2009 19:42:08 Tomasz Chmielewski wrote:
>> On my (32 bit) systems with more than 1 GB memory it is impossible to cache
>> more than about 900 MB. Why?
>>
>> Caching never goes beyond ~900 MB (i.e. when I read a mounted drive with
>> dd):
> 
> Because blockdev mappings are limited to lowmem due to sharing their
> cache with filesystem metadata cache, which needs kernel mapped memory.
> It will >900MB of pagecache data OK (data from regular files)

Does not help me, as what interests me here on these machines is mainly 
caching block device data; they are iSCSI targets and access block 
devices directly.

(...)

>> Same behaviour on 32 bit machines with 4 GB RAM.
>>
>> No problems on 64 bit machines.
>> I have one 32 bit machine that caches beyond ~900 MB without problems.
> 
> Does it have a different user/kernel split?

Yes it does:

CONFIG_VMSPLIT_2G_OPT=y


What split should I choose to enable blockdev mapping on the whole 
memory on 32 bit system with 3 or 4 GB RAM? Is it possible with 4 GB RAM 
at all?


>> Is it some kernel/proc/sys setting that I'm missing?
> 
> No, it just can't be done without changing code.


-- 
Tomasz Chmielewski
http://wpkg.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
