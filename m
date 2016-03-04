Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7086B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 07:26:22 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 4so34847811pfd.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:26:22 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id e82si5600772pfb.126.2016.03.04.04.24.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 04:26:21 -0800 (PST)
Message-ID: <56D97E05.2080106@huawei.com>
Date: Fri, 4 Mar 2016 20:22:29 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: A oops occur when it calls kmem_cache_alloc
References: <56D9491E.1020905@huawei.com> <56D96734.6050108@I-love.SAKURA.ne.jp>
In-Reply-To: <56D96734.6050108@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Linux
 Memory Management List <linux-mm@kvack.org>

On 2016/3/4 18:45, Tetsuo Handa wrote:
> On 2016/03/04 17:36, zhong jiang wrote:
>> The vmcore file show the collapse reason that the page had been removed
>> when we acqure the page and  prepare to remove the page from the slub
>>  partial list.
>>
>> The list is protected by the spin_lock from concurrent operation. And I find
>> that other core is wating the lock to alloc memory.  Therefore , The concurrent
>> access should be impossible.
>>
>> what situatios can happen ?  or it is a kernel bug potentially.  This question
>> almost impossible to produce again. The following is the call statck belonging to
>> the module.
> No kernel version, no clue.
>
>
>
   Sorry,  The kernel version is 3.4 stable version.  And The mainline , by comparison,  have no relative
   modification.

Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
