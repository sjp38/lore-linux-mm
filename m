Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88F016B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 03:49:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c202so36204288wme.10
        for <linux-mm@kvack.org>; Wed, 24 May 2017 00:49:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si17034911eda.249.2017.05.24.00.49.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 00:49:54 -0700 (PDT)
Subject: Re: mm, we use rcu access task_struct in mm_match_cgroup(), but not
 use rcu free in free_task_struct()
References: <5924E4A7.7000601@huawei.com> <59250EA3.60905@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <263518b9-5a39-1af9-ac9e-055da3384aef@suse.cz>
Date: Wed, 24 May 2017 09:49:18 +0200
MIME-Version: 1.0
In-Reply-To: <59250EA3.60905@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "wencongyang (A)" <wencongyang2@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Dmitry Vyukov <dvyukov@google.com>, zhong jiang <zhongjiang@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/24/2017 06:40 AM, Xishi Qiu wrote:
> On 2017/5/24 9:40, Xishi Qiu wrote:
> 
>> Hi, I find we use rcu access task_struct in mm_match_cgroup(), but not use
>> rcu free in free_task_struct(), is it right?
>>
>> Here is the backtrace.

Can you post the whole oops, including kernel version etc? Is it the
same 3.10 RH kernel as in the other report?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
