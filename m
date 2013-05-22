Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 311C36B0038
	for <linux-mm@kvack.org>; Wed, 22 May 2013 03:51:37 -0400 (EDT)
Message-ID: <519C78C0.3050204@huawei.com>
Date: Wed, 22 May 2013 15:50:24 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: don't initialize kmem-cache destroying work for
 root caches
References: <1368535118-27369-1-git-send-email-avagin@openvz.org> <20130514160859.GC5055@dhcp22.suse.cz> <20130522074055.GA16207@paralelels.com>
In-Reply-To: <20130522074055.GA16207@paralelels.com>
Content-Type: text/plain; charset="KOI8-R"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Vagin <avagin@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrey Vagin <avagin@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 2013/5/22 15:40, Andrew Vagin wrote:
> On Tue, May 14, 2013 at 06:08:59PM +0200, Michal Hocko wrote:
>>
>> Forgot to add
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>> +
>> Cc: stable # 3.9
>>
>> Thanks
> 
> Who usually picks up such patches?

The famous AKPM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
