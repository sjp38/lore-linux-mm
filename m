Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 09F8E6B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 06:03:48 -0500 (EST)
Received: by mail-gg0-f169.google.com with SMTP id j5so965621ggn.28
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 03:03:48 -0800 (PST)
Message-ID: <5124AD8E.9040105@gmail.com>
Date: Wed, 20 Feb 2013 19:03:42 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] a few topics I'd like to discuss
References: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com> <20130218145018.GJ4365@suse.de>
In-Reply-To: <20130218145018.GJ4365@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/18/2013 10:50 PM, Mel Gorman wrote:
> On Sun, Feb 17, 2013 at 01:44:33AM -0500, KOSAKI Motohiro wrote:
>> Sorry for the delay.
>>
>> I would like to discuss the following topics:
>>
>>
>>
>> * Hugepage migration ? Currently, hugepage is not migratable and can?t
>> use pages in ZONE_MOVABLE.  It is not happy from point of CMA/hotplug
>> view.
>>
> migrate_huge_page() ?

It seems that migrate_huge_page just called in memory failure path, why 
can't support in memory hotplug path?

>
> It's also possible to allocate hugetlbfs pages in ZONE_MOVABLE but must
> be enabled via /proc/sys/vm/hugepages_treat_as_movable.
>
>> * Remove ZONE_MOVABLE ?Very long term goal. Maybe not suitable in this year.
>>
> Whatever about removing it totally I would like to see node memory hot-remove
> not depending on ZONE_MOVABLE.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
