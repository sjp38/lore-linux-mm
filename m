Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A84E6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 04:07:30 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id y36so4184881plh.10
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 01:07:30 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id l63si4662151plb.82.2017.12.01.01.07.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 01:07:29 -0800 (PST)
Message-ID: <5A211A82.1090808@huawei.com>
Date: Fri, 1 Dec 2017 17:01:54 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86/numa: move setting parse numa node to num_add_memblk
References: <1511946807-22024-1-git-send-email-zhongjiang@huawei.com> <5A211759.5080800@huawei.com> <20171201085833.4hs6sgjvcokdrr35@dhcp22.suse.cz>
In-Reply-To: <20171201085833.4hs6sgjvcokdrr35@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, lenb@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, richard.weiyang@gmail.com, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

On 2017/12/1 16:58, Michal Hocko wrote:
> On Fri 01-12-17 16:48:25, zhong jiang wrote:
>> +cc more mm maintainer.
>>
>> Any one has any object.  please let me know.  
> Please repost with the changelog which actually tells 1) what is the
> problem 2) why do we need to address it and 3) how do we address it.
Fine,  I will repost later.

Thanks
zhong jiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
