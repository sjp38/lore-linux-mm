Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6D5786B00E7
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 14:03:42 -0500 (EST)
Message-ID: <4F4D24C8.5020405@parallels.com>
Date: Tue, 28 Feb 2012 16:02:32 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] memcg kernel memory tracking
References: <1329824079-14449-1-git-send-email-glommer@parallels.com> <CALWz4izD0Ykx8YJWVoECk7jdBLTxSm1vXOjKfkAgUaUVv2FkJw@mail.gmail.com>
In-Reply-To: <CALWz4izD0Ykx8YJWVoECk7jdBLTxSm1vXOjKfkAgUaUVv2FkJw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org

On 02/23/2012 04:18 PM, Ying Han wrote:
> On Tue, Feb 21, 2012 at 3:34 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> This is a first structured approach to tracking general kernel
>> memory within the memory controller. Please tell me what you think.
>>
>> As previously proposed, one has the option of keeping kernel memory
>> accounted separatedly, or together with the normal userspace memory.
>> However, this time I made the option to, in this later case, bill
>> the memory directly to memcg->res. It has the disadvantage that it becomes
>> complicated to know which memory came from user or kernel, but OTOH,
>> it does not create any overhead of drawing from multiple res_counters
>> at read time. (and if you want them to be joined, you probably don't care)
>
> Keeping one counter for user and kernel pages makes it easier for
> admins to configure the system. About reporting, we should still
> report the user and kernel memory separately. It will be extremely
> useful when diagnosing the system like heavily memory pressure or OOM.

It will also make us charge two different res_counters, which is not a 
cheap operation.

I was wondering if we can do something smarter within the res_counter 
itself to avoid taking locks for two different res_counters in the 
charge path?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
