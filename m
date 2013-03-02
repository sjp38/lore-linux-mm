Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 66E0C6B0005
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 19:10:59 -0500 (EST)
Received: by mail-ia0-f176.google.com with SMTP id i18so3147849iac.35
        for <linux-mm@kvack.org>; Fri, 01 Mar 2013 16:10:58 -0800 (PST)
Message-ID: <5131438B.4090507@gmail.com>
Date: Sat, 02 Mar 2013 08:10:51 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add extra free kbytes tunable
References: <alpine.DEB.2.02.1302111734090.13090@dflat> <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com> <511EB5CB.2060602@redhat.com> <alpine.DEB.2.02.1302171546120.10836@dflat> <20130219152936.f079c971.akpm@linux-foundation.org> <alpine.DEB.2.02.1302192100100.23162@dflat> <20130222175634.GA4824@cmpxchg.org> <51307354.5000401@gmail.com> <51307583.2020006@gmail.com> <alpine.LNX.2.00.1303011431290.9961@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303011431290.9961@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Mel Gorman <mel@csn.ul.ie>

On 03/02/2013 06:33 AM, Hugh Dickins wrote:
> On Fri, 1 Mar 2013, Simon Jeons wrote:
>> On 03/01/2013 05:22 PM, Simon Jeons wrote:
>>> On 02/23/2013 01:56 AM, Johannes Weiner wrote:
>>>> Mapped file pages have to get scanned twice before they are reclaimed
>>>> because we don't have enough usage information after the first scan.
>>> It seems that just VM_EXEC mapped file pages are protected.
>>> Issue in page reclaim subsystem:
>>> static inline int page_is_file_cache(struct page *page)
>>> {
>>>      return !PageSwapBacked(page);
>>> }
>>> AFAIK, PG_swapbacked is set if anonymous page added to swap cache, and be
>>> cleaned if removed from swap cache. So anonymous pages which are reclaimed
>>> and add to swap cache won't have this flag, then they will be treated as
>> s/are/aren't
> PG_swapbacked != PG_swapcache

Oh, I see. Thanks Hugh, thanks for your patient. :)

In function __add_to_swap_cache if add to radix tree successfully will 
result in increase NR_FILE_PAGES, why? This is anonymous page instead of 
file backed page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
