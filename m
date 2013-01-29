Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 68CF58D0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 11:50:32 -0500 (EST)
Message-ID: <5107FDCE.90705@oracle.com>
Date: Wed, 30 Jan 2013 00:50:22 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/6] memcg: disable swap cgroup allocation at swapon
References: <510658E3.1020306@oracle.com> <20130129151531.GI29574@dhcp22.suse.cz>
In-Reply-To: <20130129151531.GI29574@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org

On 01/29/2013 11:15 PM, Michal Hocko wrote:
> On Mon 28-01-13 18:54:27, Jeff Liu wrote:
>> Hello,
>>
>> Here is the v2 patch set for disabling swap_cgroup structures allocation
>> per swapon.
>>
>> In the initial version, one big issue is that I have missed the swap tracking
>> for the root memcg, thanks Michal pointing it out. :)
>>
>> In order to solve it, the easiest approach I can think out is to bypass the root
>> memcg swap accounting during the business and figure it out with some global stats,
>> which means that we always return 0 per root memcg swap charge/uncharge stage, and
>> this is inspired by another proposal from Zhengju:
>> "memcg: Don't account root memcg page statistics -- https://lkml.org/lkml/2013/1/2/71"
>>
>> Besides that, another major fix is deallocate swap accounting structures on the last
>> non-root memcg remove after all references to it are gone rather than doing it on
>> mem_cgroup_destroy().
>>
>> Any comment are welcome!
> 
> Could you also post your testing methodology and results, please? It
> would be also really great if you could sum up memory savings.
Sure, I'll post those info in the next try, and will revisit [PATCH v2
2/6] and answer the comments from you and Glauber since my head is not
very clear now. :)
> 
> Anyway thanks this second version looks really promising.
Thanks for your kind review, have a nice day!

-Jeff
> 
>> v1->v2:
>> - Refactor swap_cgroup_swapon()/swap_cgroup_prepare(), to make the later can be
>>   used for allocating buffers per the first non-root memcg creation.
>> - Bypass root memcg swap statistics, using the global stats to figure it out instead.
>> - Export nr_swap_files which would be used when creating/freeing swap_cgroup
>> - Deallocate swap accounting structures on the last non-root memcg removal
>>
>> Old patch set:
>> v1:
>> http://marc.info/?l=linux-mm&m=135461016823964&w=2
>>
>>
>> Thanks,
>> -Jeff
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
