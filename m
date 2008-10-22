Message-ID: <48FE8511.1090903@cn.fujitsu.com>
Date: Wed, 22 Oct 2008 09:42:41 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH][BUGFIX] memcg: fix page_cgroup allocation
References: <20081022102404.e1f3565a.kamezawa.hiroyu@jp.fujitsu.com> <20081021183738.d3c995b9.akpm@linux-foundation.org>
In-Reply-To: <20081021183738.d3c995b9.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

>> --- linux-2.6.orig/mm/page_cgroup.c
>> +++ linux-2.6/mm/page_cgroup.c
>> @@ -4,7 +4,12 @@
>>  #include <linux/bit_spinlock.h>
>>  #include <linux/page_cgroup.h>
>>  #include <linux/hash.h>
>> +#include <linux/slab.h>
>>  #include <linux/memory.h>
>> +#include <linux/cgroup.h>
>> +
>> +extern struct cgroup_subsys	mem_cgroup_subsys;
> 
> no no bad! evil! unclean!
> 
> Didn't the linux/cgroup.h -> linux/cgroup_subsys..h inclusion already
> declare this for us?
> 

Yes, I think just include <linux/cgroup.h> is enough.

#define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
#include <linux/cgroup_subsys.h>
#undef SUBSYS

and will be expanded to:

extern struct cgroup_subsys cpu_subsys;
extern struct cgroup_subsys cpuset_subsys;
extern struct cgroup_subsys memory_cgroup_subsys;
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
