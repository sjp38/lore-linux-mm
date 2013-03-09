Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id BA4696B0005
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 20:08:15 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id n34so94276dal.40
        for <linux-mm@kvack.org>; Fri, 08 Mar 2013 17:08:14 -0800 (PST)
Message-ID: <513A8B76.5000202@gmail.com>
Date: Sat, 09 Mar 2013 09:08:06 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add extra free kbytes tunable
References: <alpine.DEB.2.02.1302111734090.13090@dflat> <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com> <511EB5CB.2060602@redhat.com> <alpine.DEB.2.02.1302171546120.10836@dflat> <20130219152936.f079c971.akpm@linux-foundation.org> <alpine.DEB.2.02.1302192100100.23162@dflat> <20130222175634.GA4824@cmpxchg.org> <51307354.5000401@gmail.com> <51307583.2020006@gmail.com> <alpine.LNX.2.00.1303011431290.9961@eggly.anvils> <5131438B.4090507@gmail.com> <alpine.LNX.2.00.1303011648330.16381@eggly.anvils> <51316727.1040806@gmail.com> <alpine.LNX.2.00.1303011900430.23383@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303011900430.23383@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Mel Gorman <mel@csn.ul.ie>

Hi Hugh,
On 03/02/2013 11:08 AM, Hugh Dickins wrote:
> On Sat, 2 Mar 2013, Simon Jeons wrote:
>> On 03/02/2013 09:42 AM, Hugh Dickins wrote:
>>> On Sat, 2 Mar 2013, Simon Jeons wrote:
>>>> In function __add_to_swap_cache if add to radix tree successfully will
>>>> result
>>>> in increase NR_FILE_PAGES, why? This is anonymous page instead of file
>>>> backed
>>>> page.
>>> Right, that's hard to understand without historical background.
>>>
>>> I think the quick answer would be that we used to (and still do) think
>>> of file-cache and swap-cache as two halves of page-cache.  And then when
>> shmem page should be treated as file-cache or swap-cache? It is strange since
>> it is consist of anonymous pages and these pages establish files.
> A shmem page is swap-backed file-cache, and it may get transferred to or
> from swap-cache: yes, it's a difficult and confusing case, as I said below.
>
> I would never call it "anonymous", but it is counted in /proc/meminfo's
> Active(anon) or Inactive(anon) rather than in (file), because "anon"
> there is shorthand for "swap-backed".

In read_swap_cache_async:

SetPageSwapBacked(new_page);
__add_to_swap_cache();
swap_readpage();
ClearPageSwapBacked(new_page);

Why clear PG_swapbacked flag?

>
>>> So you'll find that shmem and swap are counted as file in some places
>>> and anon in others, and it's hard to grasp which is where and why,
>>> without remembering the history.
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
