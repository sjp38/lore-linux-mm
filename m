Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <5124B42A.1020908@gmail.com>
Date: Wed, 20 Feb 2013 19:31:54 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of get_user_pages()
 called get_user_pages_non_movable()
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com> <20130204160624.5c20a8a0.akpm@linux-foundation.org> <20130205115722.GF21389@suse.de> <20130205133244.GH21389@suse.de> <51249E3E.9070909@gmail.com> <5124A42B.1020905@cn.fujitsu.com>
In-Reply-To: <5124A42B.1020905@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, mhocko@suse.cz, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 02/20/2013 06:23 PM, Lin Feng wrote:
> Hi Simon,
>
> On 02/20/2013 05:58 PM, Simon Jeons wrote:
>>> The other is that this almost certainly broken for transhuge page
>>> handling. gup returns the head and tail pages and ordinarily this is ok
>> When need gup thp? in kvm case?
> gup just pins the wanted pages(for x86 is 4k size) of user address space in memory.
> We can't expect the pages have been allocated for user address space are thp or
> normal page. So we need to deal with them and I think it have nothing to do with kvm.

Ok, I'm curious about userspace process call which funtion(will call 
gup) to pin pages except make_pages_present?

>
> thanks,
> linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
