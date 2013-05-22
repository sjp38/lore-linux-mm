Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 9EC6F6B0069
	for <linux-mm@kvack.org>; Wed, 22 May 2013 05:21:49 -0400 (EDT)
Message-ID: <519C8ED5.5010708@cn.fujitsu.com>
Date: Wed, 22 May 2013 17:24:37 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 01/13] x86: get pg_data_t's memory from other node
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com> <1367313683-10267-2-git-send-email-tangchen@cn.fujitsu.com> <20130522085553.GB25406@gchen.bj.intel.com>
In-Reply-To: <20130522085553.GB25406@gchen.bj.intel.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gong.chen@linux.intel.com

On 05/22/2013 04:55 PM, Chen Gong wrote:
......
>> -	nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
>> +	nd_pa = memblock_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
>
> go through the implementation of memblock_alloc_try_nid, it will call
> panic when allocation fails(a.k.a alloc = 0), if so, below information
> will be never printed. Do we really need this?

Oh, yes.

We don't need this. Will remove the following in the next version.

Thanks. :)

>
>>   	if (!nd_pa) {
>> -		pr_err("Cannot find %zu bytes in node %d\n",
>> -		       nd_size, nid);
>> +		pr_err("Cannot find %zu bytes in any node\n", nd_size);
>>   		return;
>>   	}
>>   	nd = __va(nd_pa);
>> --
>> 1.7.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
