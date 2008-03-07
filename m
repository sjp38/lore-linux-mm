Message-ID: <47D086D3.20205@cn.fujitsu.com>
Date: Fri, 07 Mar 2008 09:05:39 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time
References: <20080306185952.23290.49571.sendpatchset@localhost.localdomain> <20080306111145.27efc74c.randy.dunlap@oracle.com>
In-Reply-To: <20080306111145.27efc74c.randy.dunlap@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Randy Dunlap wrote:
> On Fri, 07 Mar 2008 00:29:52 +0530 Balbir Singh wrote:
> 
>> From: Paul Menage <menage@google.com>
>>
>> The effects of cgroup_disable=foo are:
>>
>> - foo doesn't show up in /proc/cgroups
>> - foo isn't auto-mounted if you mount all cgroups in a single hierarchy
>> - foo isn't visible as an individually mountable subsystem
>>
>> As a result there will only ever be one call to foo->create(), at init
>> time; all processes will stay in this group, and the group will never
>> be mounted on a visible hierarchy. Any additional effects (e.g. not
>> allocating metadata) are up to the foo subsystem.
>>
>> This doesn't handle early_init subsystems (their "disabled" bit isn't
>> set be, but it could easily be extended to do so if any of the early_init
>> systems wanted it - I think it would just involve some nastier parameter
>> processing since it would occur before the command-line argument parser
>> had been run.
>>
>> [Balbir added Documentation/kernel-parameters updates]
>>
>> Signed-off-by: Paul Menage <menage@google.com>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  Documentation/kernel-parameters.txt |    4 ++++
>>  include/linux/cgroup.h              |    1 +
>>  kernel/cgroup.c                     |   27 +++++++++++++++++++++++++--
>>  3 files changed, 30 insertions(+), 2 deletions(-)
>>
>> diff -puN Documentation/kernel-parameters.txt~cgroup_disable Documentation/kernel-parameters.txt
>> --- linux-2.6.25-rc4/Documentation/kernel-parameters.txt~cgroup_disable	2008-03-06 17:57:32.000000000 +0530
>> +++ linux-2.6.25-rc4-balbir/Documentation/kernel-parameters.txt	2008-03-06 18:00:32.000000000 +0530
>> @@ -383,6 +383,10 @@ and is between 256 and 4096 characters. 
>>  	ccw_timeout_log [S390]
>>  			See Documentation/s390/CommonIO for details.
>>  
>> +	cgroup_disable= [KNL] Enable disable a particular controller
> 
> So it can enable or disable?  or the text has extra text?
>

don't think so, should be "Disable a particular controller"
 
>> +			Format: {name of the controller}
>> +			See /proc/cgroups for a list of compiled controllers
>> +
>>  	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
>>  			Format: { "0" | "1" }
>>  			See security/selinux/Kconfig help text.
> 
> 
> ---
> ~Randy
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
