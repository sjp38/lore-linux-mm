Received: by nf-out-0910.google.com with SMTP id h3so171302nfh.6
        for <linux-mm@kvack.org>; Fri, 28 Mar 2008 02:43:20 -0700 (PDT)
Message-ID: <47ECBDAF.9070007@gmail.com>
Date: Fri, 28 Mar 2008 10:43:11 +0100
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <47ECBD4A.8080908@gmail.com>
In-Reply-To: <47ECBD4A.8080908@gmail.com>
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 03/28/2008 10:41 AM, Jiri Slaby wrote:
>> linux-2.6.25-rc5/include/linux/mm_types.h~memory-controller-add-mm-owner    
>> 2008-03-28 09:30:47.000000000 +0530
>> +++ linux-2.6.25-rc5-balbir/include/linux/mm_types.h    2008-03-28 
>> 12:26:59.000000000 +0530
>> @@ -227,8 +227,10 @@ struct mm_struct {
>>      /* aio bits */
>>      rwlock_t        ioctx_list_lock;
>>      struct kioctx        *ioctx_list;
>> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>> -    struct mem_cgroup *mem_cgroup;
>> +#ifdef CONFIG_MM_OWNER
>> +    spinlock_t owner_lock;
>> +    struct task_struct *owner;    /* The thread group leader that */
> 
> Doesn't make sense to switch them (spinlock is unsigned int on x86, 
> what's sizeof between and after?)?

Hmm, doesn't matter, there is another pointer after it, ignore me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
