Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 9F5E46B0034
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 04:49:30 -0400 (EDT)
Message-ID: <51CBFC95.9070002@yandex-team.ru>
Date: Thu, 27 Jun 2013 12:49:25 +0400
From: Roman Gushchin <klamm@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: Avoid direct compaction if possible
References: <51BB1802.8050108@yandex-team.ru> <0000013f4319cb46-a5a3de58-1207-4037-ae39-574b58135ea2-000000@email.amazonses.com> <alpine.DEB.2.02.1306141322490.17237@chino.kir.corp.google.com> <51BF024F.2080609@yandex-team.ru> <20130617142715.GB8853@dhcp22.suse.cz> <51BF230E.8050904@yandex-team.ru> <alpine.DEB.2.02.1306171441510.20631@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1306171441510.20631@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@gentwo.org>, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, mgorman@suse.de, glommer@parallels.com, hannes@cmpxchg.org, minchan@kernel.org, jiang.liu@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 18.06.2013 01:44, David Rientjes wrote:
> On Mon, 17 Jun 2013, Roman Gushchin wrote:

> They certainly aren't enough, the kernel you're running suffers from a
> couple different memory compaction issues that were fixed in 3.7.  I
> couldn't sympathize with your situation more, I faced the same issue
> because of thp and not slub (we use slab).
>
>> I'll try to reproduce the issue on raw 3.9.
>>

I can't reproduce the issue on 3.9.
It seems that compaction fixes in 3.7 solve the problem.

>
> Thanks.  If you need to go back to 3.4, try using these, they
> significantly helped our issues:
>
> bb13ffeb9f6bfeb301443994dfbf29f91117dfb3
> 627260595ca6abcb16d68a3732bac6b547e112d6
> c89511ab2f8fe2b47585e60da8af7fd213ec877e
> 62997027ca5b3d4618198ed8b1aba40b61b1137b
> a9aacbccf3145355190d87f0df1731fb84fdd8c8

Thank you!

Regards,
Roman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
