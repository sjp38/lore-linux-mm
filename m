Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id ED4816B0034
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 22:30:22 -0400 (EDT)
Message-ID: <521425FF.0@asianux.com>
Date: Wed, 21 Aug 2013 10:29:19 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: readahead: return the value which force_page_cache_readahead()
 returns
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org>
In-Reply-To: <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On 08/21/2013 07:16 AM, Andrew Morton wrote:
> On Tue, 20 Aug 2013 11:31:52 +0800 Chen Gang <gang.chen@asianux.com> wrote:
> 
>> force_page_cache_readahead() may fail, so need let the related upper
>> system calls know about it by its return value.
>>
>> Also let related code pass "scripts/checkpatch.pl's" checking.
>>
>> --- a/mm/fadvise.c
>> +++ b/mm/fadvise.c
>> @@ -107,8 +107,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
>>  		 * Ignore return value because fadvise() shall return
>>  		 * success even if filesystem can't retrieve a hint,
>>  		 */
> 
> 		^^ look.
> 

Oh, thanks.

It is my fault, I will send patch v2 for it.

>> -		force_page_cache_readahead(mapping, f.file, start_index,
>> -					   nrpages);
>> +		ret = force_page_cache_readahead(mapping, f.file, start_index,
>> +						 nrpages);
>>  		break;
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
