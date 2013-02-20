Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <5124B991.1020302@cn.fujitsu.com>
Date: Wed, 20 Feb 2013 19:54:57 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of get_user_pages()
 called get_user_pages_non_movable()
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com> <20130204160624.5c20a8a0.akpm@linux-foundation.org> <20130205115722.GF21389@suse.de> <20130205133244.GH21389@suse.de> <51249E3E.9070909@gmail.com> <5124A42B.1020905@cn.fujitsu.com> <5124B42A.1020908@gmail.com>
In-Reply-To: <5124B42A.1020908@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, mhocko@suse.cz, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org



On 02/20/2013 07:31 PM, Simon Jeons wrote:
> On 02/20/2013 06:23 PM, Lin Feng wrote:
>> Hi Simon,
>>
>> On 02/20/2013 05:58 PM, Simon Jeons wrote:
>>>> The other is that this almost certainly broken for transhuge page
>>>> handling. gup returns the head and tail pages and ordinarily this is ok
>>> When need gup thp? in kvm case?
>> gup just pins the wanted pages(for x86 is 4k size) of user address space in memory.
>> We can't expect the pages have been allocated for user address space are thp or
>> normal page. So we need to deal with them and I think it have nothing to do with kvm.
> 
> Ok, I'm curious about userspace process call which funtion(will call gup) to pin pages except make_pages_present?
No, userspace process doesn't pin any pages directly but through some syscalls like io_setup() indirectly
for other purpose because kernel can't pagefault and it have to keep the page alive.
Kernel wants to communicate with the userspace such as to notify some events so it need some sort of buffer
that both Kernel and User space can both access, which leads to so called pin pages by gup.  

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
