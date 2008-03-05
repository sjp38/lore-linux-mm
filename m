Message-Id: <47CE5F0A.7040801@mxp.nes.nec.co.jp>
Date: Wed, 05 Mar 2008 17:51:22 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] cgroup swap subsystem
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <47CE5AE2.2050303@openvz.org>
In-Reply-To: <47CE5AE2.2050303@openvz.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi.

>> @@ -664,6 +665,10 @@ retry:
>>  	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
>>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
>>  		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
>> +#ifdef CONFIG_CGROUP_SWAP_LIMIT
>> +	atomic_inc(&mm->mm_count);
>> +	pc->pc_mm = mm;
>> +#endif
> 
> What kernel is this patch for? I cannot find this code in 2.6.25-rc3-mm1
> 
For linux-2.6.24-mm1.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
