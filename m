Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 825A96B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 03:51:05 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8599451dak.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 00:51:04 -0700 (PDT)
Message-ID: <4FF152E6.70009@gmail.com>
Date: Mon, 02 Jul 2012 15:51:02 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] Per-cgroup page stat accounting
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <4FED6604.9080603@jp.fujitsu.com>
In-Reply-To: <4FED6604.9080603@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 06/29/2012 04:23 PM, Kamezawa Hiroyuki wrote:
> (2012/06/28 19:54), Sha Zhengju wrote:
>> This patch series provide the ability for each memory cgroup to have independent
>> dirty/writeback page stats. This can provide some information for per-cgroup direct
>> reclaim. Meanwhile, we add more detailed dump messages for memcg OOMs.
>>
>> Three features are included in this patch series:
>>   (0).prepare patches for page accounting
>>    1. memcg dirty page accounting
>>    2. memcg writeback page accounting
>>    3. memcg OOMs dump info
>>
>> In (0) prepare patches, we have reworked vfs set page dirty routines to make "modify
>> page info" and "dirty page accouting" stay in one function as much as possible for
>> the sake of memcg bigger lock.
>>
>> These patches are cooked based on Andrew's akpm tree.
>>
> Thank you !, it seems good in general. I'll review in detail, later.
>
> Do you have any performance comparison between before/after the series ?
> I mean, set_page_dirty() is the hot-path and we should be careful to add a new accounting.


Not yet, I sent it out as soon as I worked out this solution to check
whether it's okay.
I can test the series after most of people agree with it.


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
