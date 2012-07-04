Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id F2F9F6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 07:20:59 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so7803448ghr.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 04:20:58 -0700 (PDT)
Message-ID: <4FF42711.50303@gmail.com>
Date: Wed, 04 Jul 2012 19:20:49 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] memcg: print more detailed info while memcg oom happening
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <1340881609-5935-1-git-send-email-handai.szj@taobao.com> <4FF3FED6.9010700@jp.fujitsu.com>
In-Reply-To: <4FF3FED6.9010700@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 07/04/2012 04:29 PM, Kamezawa Hiroyuki wrote:
> (2012/06/28 20:06), Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> While memcg oom happening, the dump info is limited, so add this
>> to provide memcg page stat.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Could you split this into a different series ?
> seems good to me in general but...one concern is hierarchy handling.
>
> IIUC, the passed 'memcg' is the root of hierarchy which gets OOM.
> So, the LRU info, which is local to the root memcg, may not contain any good
> information. I think you should visit all memcg under the tree.
>
Yes, you're right!
I did not handle hierarchy here, and just now I make a test case to
prove this.
I'll split it to another series later.

Thanks for reviewing!


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
