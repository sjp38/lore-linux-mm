Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC216B0035
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 14:28:02 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id gq1so7038724obb.31
        for <linux-mm@kvack.org>; Tue, 24 Dec 2013 11:28:02 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id so9si19111816oeb.140.2013.12.24.11.28.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Dec 2013 11:28:01 -0800 (PST)
Message-ID: <52B9E037.1050606@oracle.com>
Date: Tue, 24 Dec 2013 14:27:51 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
References: <52B1C143.8080301@oracle.com> <52B871B2.7040409@oracle.com> <20131224025127.GA2835@lge.com> <52B8F8F6.1080500@oracle.com> <20131224060705.GA16140@lge.com>
In-Reply-To: <20131224060705.GA16140@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>

On 12/24/2013 01:07 AM, Joonsoo Kim wrote:
> On Mon, Dec 23, 2013 at 10:01:10PM -0500, Sasha Levin wrote:
>> On 12/23/2013 09:51 PM, Joonsoo Kim wrote:
>>> On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin wrote:
>>>>> Ping?
>>>>>
>>>>> I've also Cc'ed the "this page shouldn't be locked at all" team.
>>> Hello,
>>>
>>> I can't find the reason of this problem.
>>> If it is reproducible, how about bisecting?
>>
>> While it reproduces under fuzzing it's pretty hard to bisect it with
>> the amount of issues uncovered by trinity recently.
>>
>> I can add any debug code to the site of the BUG if that helps.
>
> Good!
> It will be helpful to add dump_page() in migration_entry_to_page().


[ 3800.520039] page:ffffea0000245800 count:12 mapcount:4 mapping:ffff88001d0c3668 index:0x7de
[ 3800.521404] page flags: 
0x1fffff8038003c(referenced|uptodate|dirty|lru|swapbacked|unevictable|mlocked)
[ 3800.522585] pc:ffff88001ed91600 pc->flags:2 pc->mem_cgroup:ffffc90000c0a000


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
