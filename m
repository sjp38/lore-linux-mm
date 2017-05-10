Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1AE4831FD
	for <linux-mm@kvack.org>; Tue,  9 May 2017 22:15:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q125so14614306pgq.8
        for <linux-mm@kvack.org>; Tue, 09 May 2017 19:15:55 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTP id f19si1681646pgn.104.2017.05.09.19.15.53
        for <linux-mm@kvack.org>;
        Tue, 09 May 2017 19:15:55 -0700 (PDT)
Message-ID: <5912779D.3020908@huawei.com>
Date: Wed, 10 May 2017 10:14:53 +0800
From: zhong jiang <zhongjiang@huawei.com>
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
Cc: David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andrew Morton <akpm@linux-foundation.org>, arnd@arndb.de, hannes@cmpxchg.org, kirill@shutemov.name, mgorman@techsingularity.net, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>

On 2017/5/9 23:46, Rik van Riel wrote:
> On Thu, 2017-05-04 at 10:28 +0800, zhong jiang wrote:
>> On 2017/5/4 2:46, Rik van Riel wrote:
>>> However, it is not as easy as simply checking the
>>> end against __pa(high_memory). Some systems have
>>> non-contiguous physical memory ranges, with gaps
>>> of invalid addresses in-between.
>>  The invalid physical address means that it is used as
>>  io mapped. not in system ram region. /dev/mem is not
>>  access to them , is it right?
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
>>> At that point, is the complexity so much that it no
>>> longer makes sense to try to protect against root
>>> crashing the system?
>>>
>>  your suggestion is to let the issue along without any protection.
>>  just root user know what they are doing.
> Well, root already has other ways to crash the system.
>
> Implementing validation on /dev/mem may make sense if
> it can be done in a simple way, but may not be worth
> it if it becomes too complex.
>
 I have no a simple way to fix. Do you any suggestion. or you can send
 a patch for me ?

 Thanks
 zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
