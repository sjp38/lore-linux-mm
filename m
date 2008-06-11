Received: by fg-out-1718.google.com with SMTP id 19so2100654fgg.4
        for <linux-mm@kvack.org>; Wed, 11 Jun 2008 11:48:51 -0700 (PDT)
Message-ID: <48501E1B.70703@gmail.com>
Date: Wed, 11 Jun 2008 20:48:59 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain> <20080521152948.15001.39361.sendpatchset@localhost.localdomain> <4850070F.6060305@gmail.com> <48500C66.7040807@linux.vnet.ibm.com>
In-Reply-To: <48500C66.7040807@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Andrea Righi wrote:
>> Balbir Singh wrote:
>>> +static int memrlimit_cgroup_write_strategy(char *buf, unsigned long
>>> long *tmp)
>>> +{
>>> +    *tmp = memparse(buf, &buf);
>>> +    if (*buf != '\0')
>>> +        return -EINVAL;
>>> +
>>> +    *tmp = PAGE_ALIGN(*tmp);
>>> +    return 0;
>>> +}
>> We shouldn't use PAGE_ALIGN() here, otherwise we limit the address space
>> to 4GB on 32-bit architectures (that could be reasonable, because this
>> is a per-cgroup limit and not per-process).
>>
> 
> You mean un-reasonable?

well... I mean, there would be no reason to apply this fix if it was a
limit per-task on 32-bit. ;-)

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
