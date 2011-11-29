Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 708266B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 12:50:08 -0500 (EST)
Message-ID: <4ED51B48.6020202@redhat.com>
Date: Tue, 29 Nov 2011 12:50:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] MIPS: changes in VM core for adding THP
References: <CAJd=RBB2gSCaJSsFfJXBg2zmgzNjXPAn8OakAZACNG0mv2D7nQ@mail.gmail.com> <20111126173151.GF8397@redhat.com>
In-Reply-To: <20111126173151.GF8397@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hillf Danton <dhillf@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Daney <ddaney.cavm@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, linux-mm@kvack.org

On 11/26/2011 12:31 PM, Andrea Arcangeli wrote:
> On Sat, Nov 26, 2011 at 10:43:15PM +0800, Hillf Danton wrote:
>> In VM core, window is opened for MIPS to use THP.
>>
>> And two simple helper functions are added to easy MIPS a bit.
>>
>> Signed-off-by: Hillf Danton<dhillf@gmail.com>
>> ---
>>
>> --- a/mm/Kconfig	Thu Nov 24 21:12:00 2011
>> +++ b/mm/Kconfig	Sat Nov 26 22:12:56 2011
>> @@ -307,7 +307,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
>>
>>   config TRANSPARENT_HUGEPAGE
>>   	bool "Transparent Hugepage Support"
>> -	depends on X86&&  MMU
>> +	depends on MMU
>>   	select COMPACTION
>>   	help
>>   	  Transparent Hugepages allows the kernel to use huge pages and
>
> Then the build will break for all archs if they enable it, better to
> limit the option to those archs that supports it.

Would it be an idea to define ARCH_HAVE_HUGEPAGE in the
arch specific Kconfig file and test against that in
mm/Kconfig ?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
