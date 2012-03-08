Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 9AF376B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 02:02:54 -0500 (EST)
Received: by dadv6 with SMTP id v6so192407dad.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 23:02:53 -0800 (PST)
Message-ID: <4F58599A.3090100@gmail.com>
Date: Thu, 08 Mar 2012 15:02:50 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: revise the position of threshold index while unregistering
 event
References: <1331035943-7456-1-git-send-email-handai.szj@taobao.com> <20120308144448.889337cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120308144448.889337cf.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

On 03/08/2012 01:44 PM, KAMEZAWA Hiroyuki wrote:
> On Tue,  6 Mar 2012 20:12:23 +0800
> Sha Zhengju<handai.szj@gmail.com>  wrote:
>
>> From: Sha Zhengju<handai.szj@taobao.com>
>>
>> Index current_threshold should point to threshold just below or equal to usage.
>> See below:
>> http://www.spinics.net/lists/cgroups/msg00844.html
>>
>>
>> Signed-off-by: Sha Zhengju<handai.szj@taobao.com>
> Thank you for resending.
>
> Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
It's not a resending, though they are for the same reason.  May be I should
merge them together ...


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
