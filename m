Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 793F96B0027
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 20:27:24 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id um15so1121919pbc.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 17:27:23 -0700 (PDT)
Message-ID: <515CC8E6.3000402@gmail.com>
Date: Thu, 04 Apr 2013 08:27:18 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: System freezes when RAM is full (64-bit)
References: <5159DCA0.3080408@gmail.com> <20130403121220.GA14388@dhcp22.suse.cz>
In-Reply-To: <20130403121220.GA14388@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ivan Danov <huhavel@gmail.com>, linux-mm@kvack.org, 1162073@bugs.launchpad.net

On 04/03/2013 08:12 PM, Michal Hocko wrote:
> On Mon 01-04-13 21:14:40, Ivan Danov wrote:
>> The system freezes when RAM gets completely full. By using MATLAB, I
>> can get all 8GB RAM of my laptop full and it immediately freezes,
>> needing restart using the hardware button.
> Do you use swap (file/partition)? How big? Could you collect
> /proc/meminfo and /proc/vmstat (every few seconds)[1]?
> What does it mean when you say the system freezes? No new processes can
> be started or desktop environment doesn't react on your input? Do you
> see anything in the kernel log? OOM killer e.g.
> In case no new processes could be started what does sysrq+m say when the
> system is frozen?
>
> What is your kernel config?
>
>> Other people have
>> reported the bug at since 2007. It seems that only the 64-bit
>> version is affected and people have reported that enabling DMA in
>> BIOS settings solve the problem. However, my laptop lacks such an
>> option in the BIOS settings, so I am unable to test it. More
>> information about the bug could be found at:
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1162073 and
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/159356.
>>
>> Best Regards,
>> Ivan
>>
> ---
> [1] E.g. by
> while true
> do
> 	STAMP=`date +%s`
> 	cat /proc/meminfo > meminfo.$STAMP
> 	cat /proc/vmscan > meminfo.$STAMP

s/vmscan/vmstat

> 	sleep 2s
> done

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
