Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF478831FD
	for <linux-mm@kvack.org>; Tue,  9 May 2017 22:16:57 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o25so14752964pgc.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 19:16:57 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id b6si1636627pfa.364.2017.05.09.19.16.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 19:16:56 -0700 (PDT)
Message-ID: <591277AE.80908@huawei.com>
Date: Wed, 10 May 2017 10:15:10 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RESENT PATCH] x86/mem: fix the offset overflow when read/write
 mem
References: <1493293775-57176-1-git-send-email-zhongjiang@huawei.com>   <alpine.DEB.2.10.1705021350510.116499@chino.kir.corp.google.com>  <1493837167.20270.8.camel@redhat.com> <590A91DF.8030004@huawei.com> <1494344803.20270.27.camel@redhat.com>
In-Reply-To: <1494344803.20270.27.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: zhong jiang <zhongjiang@huawei.com>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andrew Morton <akpm@linux-foundation.org>, arnd@arndb.de, hannes@cmpxchg.org, kirill@shutemov.name, mgorman@techsingularity.net, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/5/9 23:46, Rik van Riel wrote:

> On Thu, 2017-05-04 at 10:28 +0800, zhong jiang wrote:
>> On 2017/5/4 2:46, Rik van Riel wrote:
> 
>>> However, it is not as easy as simply checking the
>>> end against __pa(high_memory). Some systems have
>>> non-contiguous physical memory ranges, with gaps
>>> of invalid addresses in-between.
>>
>>  The invalid physical address means that it is used as
>>  io mapped. not in system ram region. /dev/mem is not
>>  access to them , is it right?
> 
> Not necessarily. Some systems simply have large
> gaps in physical memory access. Their memory map
> may look like this:
> 
> |MMMMMM|IO|MMMM|..................|MMMMMMMM|
> 
> Where M is memory, IO is IO space, and the
> dots are simply a gap in physical address
> space with no valid accesses at all.
>

Hi Rik,

Do you mean IO space is allowed to access from mmap /dev/mem?

Thanks,
Xishi Qiu

 
>>> At that point, is the complexity so much that it no
>>> longer makes sense to try to protect against root
>>> crashing the system?
>>>
>>
>>  your suggestion is to let the issue along without any protection.
>>  just root user know what they are doing.
> 
> Well, root already has other ways to crash the system.
> 
> Implementing validation on /dev/mem may make sense if
> it can be done in a simple way, but may not be worth
> it if it becomes too complex.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
