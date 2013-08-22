Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 98D8E6B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 20:53:14 -0400 (EDT)
Message-ID: <521560BB.30006@asianux.com>
Date: Thu, 22 Aug 2013 08:52:11 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm/shmem.c: let shmem_show_mpol() return value.
References: <5212E8DF.5020209@asianux.com> <20130820053036.GB18673@moon> <52130194.4030903@asianux.com> <20130820064730.GD18673@moon> <52131F48.1030002@asianux.com> <52132011.60501@asianux.com> <52132432.3050308@asianux.com> <20130820082516.GE18673@moon> <52142422.9050209@asianux.com> <52142464.8060903@asianux.com> <521424BE.8020309@asianux.com> <20130821150337.bad5f71869cec813e2ded90c@linux-foundation.org>
In-Reply-To: <20130821150337.bad5f71869cec813e2ded90c@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 08/22/2013 06:03 AM, Andrew Morton wrote:
> On Wed, 21 Aug 2013 10:23:58 +0800 Chen Gang <gang.chen@asianux.com> wrote:
> 
>> Let shmem_show_mpol() return value, since it may fail.
>>
> 
> This patch has no effect.
> 
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -883,16 +883,17 @@ redirty:
>>  
>>  #ifdef CONFIG_NUMA
>>  #ifdef CONFIG_TMPFS
>> -static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>> +static int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>>  {
>>  	char buffer[64];
>>  
>>  	if (!mpol || mpol->mode == MPOL_DEFAULT)
>> -		return;		/* show nothing */
>> +		return 0;		/* show nothing */
>>  
>>  	mpol_to_str(buffer, sizeof(buffer), mpol);
> 
> Perhaps you meant to check the mpol_to_str() return value here.
> 

Yes, I will merge them together (merge Patch 2/3 and Patch 3/3).

>>  	seq_printf(seq, ",mpol=%s", buffer);
>> +	return 0;
>>  }
>>  
>>  static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
> 
> 
> 

Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
