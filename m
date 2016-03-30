Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id AFDB96B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 05:44:12 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id x3so38065635pfb.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 02:44:12 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id tb4si5314558pab.121.2016.03.30.02.43.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Mar 2016 02:44:12 -0700 (PDT)
Message-ID: <56FB9EE3.7010208@huawei.com>
Date: Wed, 30 Mar 2016 17:39:47 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: why cat /proc/pid/smaps | grep Rss is different from
 cat /proc/pid/statm?
References: <56F14EEE.7060308@huawei.com> <CALvZod5PnHz5OsNrcfsMZ6=cxLBy9436htbKerv67S+CigwGbQ@mail.gmail.com> <56FB7D37.5070503@huawei.com>
In-Reply-To: <56FB7D37.5070503@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/3/30 15:16, Xishi Qiu wrote:

> On 2016/3/22 22:47, Shakeel Butt wrote:
> 
>>
>> On Tue, Mar 22, 2016 at 6:55 AM, Xishi Qiu <qiuxishi@huawei.com <mailto:qiuxishi@huawei.com>> wrote:
>>
>>     [root@localhost c_test]# cat /proc/3948/smaps | grep Rss
>>
>> The /proc/[pid]/smaps read triggers the traversal of all of process's vmas and then page tables and accumulate RSS on each present page table entry.
>>
>>     [root@localhost c_test]# cat /proc/3948/statm
>>     1042 173 154 1 0 48 0
>>
>> The files /proc/[pid]/statm and /proc/[pid]/status uses the counters (MM_ANONPAGES & MM_FILEPAGES) in mm_struct to report RSS of a process. These counters are modified on page table modifications. However the kernel implements an optimization where each thread keeps a local copy of these counters in its task_struct. These local counter are accumulated in the shared counter of mm_struct after some number of page faults (I think 32) faced by the thread and thus there will be mismatch with smaps file.
>>
>> Shakeel
> 

Hi Shakeel,

I misunderstand your meaning before. I know the reason now.

Thanks,
Xishi Qiu 

> Hi Shakeel,
> 
> I malloc and memset 10M, then sleep. It seems that the problem is still exist,
> the kernel version is v4.1
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
