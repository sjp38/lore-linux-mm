Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B05BA6B01F2
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 23:37:23 -0400 (EDT)
Message-ID: <4BBAAC58.80108@redhat.com>
Date: Mon, 05 Apr 2010 23:36:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
References: <20100331145602.03A7.A69D9226@jp.fujitsu.com> <20100401151639.a030fb10.akpm@linux-foundation.org> <20100402180812.646D.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100402180812.646D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 04/02/2010 05:13 AM, KOSAKI Motohiro wrote:
>>> Yeah, I don't want ignore .33-stable too. if I can't find the root cause
>>> in 2-3 days, I'll revert guilty patch anyway.
>>>
>>
>> It's a good idea to avoid fixing a bug one-way-in-stable,
>> other-way-in-mainline.  Because then we have new code in both trees
>> which is different.  And the -stable guys sensibly like to see code get
>> a bit of a shakedown in mainline before backporting it.
>>
>> So it would be better to merge the "simple" patch into mainline, tagged
>> for -stable backporting.  Then we can later implement the larger fix in
>> mainline, perhaps starting by reverting the "simple" fix.
>
> .....ok. I don't have to prevent your code maintainship. although I still
> think we need to fix the issue completely.

Agreed on the revert.

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
