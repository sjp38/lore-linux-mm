Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8C6506B0072
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 05:10:57 -0400 (EDT)
Message-ID: <5150151E.7070206@cn.fujitsu.com>
Date: Mon, 25 Mar 2013 17:13:02 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: mm: add_pfn_range_mapped: use meaningful index to
 teach clean_sort_range()
References: <1363602093-11965-1-git-send-email-linfeng@cn.fujitsu.com> <CAE9FiQUHtM_Nuz4ak+HeNGV6a-HTtfMkxc+zBZuow47Vj70CKQ@mail.gmail.com>
In-Reply-To: <CAE9FiQUHtM_Nuz4ak+HeNGV6a-HTtfMkxc+zBZuow47Vj70CKQ@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, penberg@kernel.org, jacob.shin@amd.com

Hi Andrew,

On 03/19/2013 02:52 AM, Yinghai Lu wrote:
> On Mon, Mar 18, 2013 at 3:21 AM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
>> Since add_range_with_merge() return the max none zero element of the array, it's
>> suffice to use it to instruct clean_sort_range() to do the sort. Or the former
>> assignment by add_range_with_merge() is nonsense because clean_sort_range()
>> will produce a accurate number of the sorted array and it never depends on
>> nr_pfn_mapped.
>>
>> Cc: Jacob Shin <jacob.shin@amd.com>
>> Cc: Yinghai Lu <yinghai@kernel.org>
>> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
>> ---
>>  arch/x86/mm/init.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
>> index 59b7fc4..55ae904 100644
>> --- a/arch/x86/mm/init.c
>> +++ b/arch/x86/mm/init.c
>> @@ -310,7 +310,7 @@ static void add_pfn_range_mapped(unsigned long start_pfn, unsigned long end_pfn)
>>  {
>>         nr_pfn_mapped = add_range_with_merge(pfn_mapped, E820_X_MAX,
>>                                              nr_pfn_mapped, start_pfn, end_pfn);
>> -       nr_pfn_mapped = clean_sort_range(pfn_mapped, E820_X_MAX);
>> +       nr_pfn_mapped = clean_sort_range(pfn_mapped, nr_pfn_mapped);
>>
>>         max_pfn_mapped = max(max_pfn_mapped, end_pfn);>
> 
> Acked-by: Yinghai Lu <yinghai@kernel.org>

Do we need to pick up this patch?

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
