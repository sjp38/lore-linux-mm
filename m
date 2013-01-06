Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 1E3F96B005D
	for <linux-mm@kvack.org>; Sat,  5 Jan 2013 21:55:44 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id l10so16097498oag.8
        for <linux-mm@kvack.org>; Sat, 05 Jan 2013 18:55:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50DCF185.7050408@jp.fujitsu.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
	<1356456501-14818-1-git-send-email-handai.szj@taobao.com>
	<50DCF185.7050408@jp.fujitsu.com>
Date: Sun, 6 Jan 2013 10:55:43 +0800
Message-ID: <CAFj3OHWyMoF=ykaneD-tBMoDrBfWT6VrUWQ871CHPTxU=Ce5jg@mail.gmail.com>
Subject: Re: [PATCH V3 8/8] memcg: Document cgroup dirty/writeback memory statistics
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

On Fri, Dec 28, 2012 at 9:10 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/12/26 2:28), Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>
> I don't think your words are bad but it may be better to sync with meminfo's text.
>
>> ---
>>   Documentation/cgroups/memory.txt |    2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
>> index addb1f1..2828164 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -487,6 +487,8 @@ pgpgin            - # of charging events to the memory cgroup. The charging
>>   pgpgout             - # of uncharging events to the memory cgroup. The uncharging
>>               event happens each time a page is unaccounted from the cgroup.
>>   swap                - # of bytes of swap usage
>> +dirty          - # of bytes of file cache that are not in sync with the disk copy.
>> +writeback      - # of bytes of file/anon cache that are queued for syncing to disk.
>>   inactive_anon       - # of bytes of anonymous memory and swap cache memory on
>>               LRU list.
>>   active_anon - # of bytes of anonymous and swap cache memory on active
>>
>
> Documentation/filesystems/proc.txt
>
>        Dirty: Memory which is waiting to get written back to the disk
>    Writeback: Memory which is actively being written back to the disk
>
> even if others are not ;(
>


The words are actually revised by Fengguang before:
https://lkml.org/lkml/2012/7/7/49
It might be more accurate than previous one and I just follow his advise...


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
