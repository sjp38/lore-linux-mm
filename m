Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 608496B005C
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 04:24:42 -0400 (EDT)
Received: by ggm4 with SMTP id 4so7608019ggm.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 01:24:41 -0700 (PDT)
Message-ID: <4FF3FDC3.9070108@gmail.com>
Date: Wed, 04 Jul 2012 16:24:35 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] memcg: add per cgroup writeback pages accounting
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <1340881525-5835-1-git-send-email-handai.szj@taobao.com> <4FF291BE.7030509@jp.fujitsu.com>
In-Reply-To: <4FF291BE.7030509@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 07/03/2012 02:31 PM, Kamezawa Hiroyuki wrote:
> (2012/06/28 20:05), Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Similar to dirty page, we add per cgroup writeback pages accounting. The lock
>> rule still is:
>> 	mem_cgroup_begin_update_page_stat()
>> 	modify page WRITEBACK stat
>> 	mem_cgroup_update_page_stat()
>> 	mem_cgroup_end_update_page_stat()
>>
>> There're two writeback interface to modify: test_clear/set_page_writeback.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Seems good to me. BTW, you named macros as MEM_CGROUP_STAT_FILE_XXX
> but I wonder these counters will be used for accounting swap-out's dirty pages..
>
> STAT_DIRTY, STAT_WRITEBACK ? do you have better name ?

Okay, STAT_DIRTY/WRITEBACK seem good, I'll change them in next version.


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
