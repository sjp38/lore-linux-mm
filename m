Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 566956B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 15:51:03 -0400 (EDT)
Message-ID: <4BFAD899.4020909@redhat.com>
Date: Mon, 24 May 2010 15:50:49 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
Subject: Re: RFC: dirty_ratio back to 40%
References: <4BF51B0A.1050901@redhat.com> <20100521083408.1E36.A69D9226@jp.fujitsu.com> <4BF5D875.3030900@acm.org>
In-Reply-To: <4BF5D875.3030900@acm.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Zan Lynx <zlynx@acm.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On 05/20/2010 08:48 PM, Zan Lynx wrote:
> On 5/20/10 5:48 PM, KOSAKI Motohiro wrote:
>> Hi
>>
>> CC to Nick and Jan
>>
>>> We've seen multiple performance regressions linked to the lower(20%)
>>> dirty_ratio.  When performing enough IO to overwhelm the background
>>> flush daemons the percent of dirty pagecache memory quickly climbs
>>> to the new/lower dirty_ratio value of 20%.  At that point all writing
>>> processes are forced to stop and write dirty pagecache pages back to 
>>> disk.
>>> This causes performance regressions in several benchmarks as well as 
>>> causing
>>> a noticeable overall sluggishness.  We all know that the dirty_ratio is
>>> an integrity vs performance trade-off but the file system journaling
>>> will cover any devastating effects in the event of a system crash.
>>>
>>> Increasing the dirty_ratio to 40% will regain the performance loss seen
>>> in several benchmarks.  Whats everyone think about this???
>>
>> In past, Jan Kara also claim the exactly same thing.
>>
>>     Subject: [LSF/VM TOPIC] Dynamic sizing of dirty_limit
>>     Date: Wed, 24 Feb 2010 15:34:42 +0100
>>
>> >  (*) We ended up increasing dirty_limit in SLES 11 to 40% as it 
>> used to be
>> >  with old kernels because customers running e.g. LDAP (using BerkelyDB
>> >  heavily) were complaining about performance problems.
>>
>> So, I'd prefer to restore the default rather than both Redhat and 
>> SUSE apply exactly
>> same distro specific patch. because we can easily imazine other users 
>> will face the same
>> issue in the future.
>
> On desktop systems the low dirty limits help maintain interactive 
> feel. Users expect applications that are saving data to be slow. They 
> do not like it when every application in the system randomly comes to 
> a halt because of one program stuffing data up to the dirty limit.
>
> The cause and effect for the system slowdown is clear when the dirty 
> limit is low. "I saved data and now the system is slow until it is 
> done." When the dirty page ratio is very high, the cause and effect is 
> disconnected. "I was just web surfing and the system came to a halt."
>
> I think we should expect server admins to do more tuning than desktop 
> users, so the default limits should stay low in my opinion.
>

Have you done any performance testing that shows this?

A laptop the smaller default would spin up drives more often and greatly 
decrease your battery life.

Note that both SLES and RHEL default away from the upstream default.

Ric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
