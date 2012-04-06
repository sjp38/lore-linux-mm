Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 583A86B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 23:59:55 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2613083pbc.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 20:59:54 -0700 (PDT)
Message-ID: <4F7E6A35.10901@gmail.com>
Date: Fri, 06 Apr 2012 11:59:49 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: revise the position of threshold index while unregistering
 event
References: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>	<20120405163530.a1a9c9f9.akpm@linux-foundation.org> <20120405163758.b2ef6c45.akpm@linux-foundation.org>
In-Reply-To: <20120405163758.b2ef6c45.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

On 04/06/2012 07:37 AM, Andrew Morton wrote:
> On Thu, 5 Apr 2012 16:35:30 -0700
> Andrew Morton<akpm@linux-foundation.org>  wrote:
>
>> On Tue,  6 Mar 2012 20:12:23 +0800
>> Sha Zhengju<handai.szj@gmail.com>  wrote:
>>
>>> From: Sha Zhengju<handai.szj@taobao.com>
>>>
>>> Index current_threshold should point to threshold just below or equal to usage.
>>> See below:
>>> http://www.spinics.net/lists/cgroups/msg00844.html
>> I have a bad feeling that I looked at a version of this patch
>> yesterday, but I can't find it.
> Found it!  Below.
>
> I think we might as well fold "memcg: revise the position of threshold
> index while unregistering event" into the below "memcg: make threshold
> index in the right position" as a single patch?
>

Yeah, actually I've already sent a folded one before(maybe I should
mark it as V2):
http://www.spinics.net/lists/cgroups/msg01133.html

Thanks,
Sha


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
