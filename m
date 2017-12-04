Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69DF46B0271
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 06:53:56 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 11so9912508wrb.18
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 03:53:56 -0800 (PST)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id l16si10045853wrb.447.2017.12.04.03.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 03:53:55 -0800 (PST)
Message-ID: <5A2536B0.5060804@huawei.com>
Date: Mon, 4 Dec 2017 19:51:12 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [patch 13/15] mm/page_owner: align with pageblock_nr pages
References: <5a208318./AHclpWAWggUsQYT%akpm@linux-foundation.org> <8c2af1ab-e64f-21da-f295-ea1ead343206@suse.cz> <20171201171517.lyqukuvuh4cswnla@dhcp22.suse.cz>
In-Reply-To: <20171201171517.lyqukuvuh4cswnla@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, linux-mm@kvack.org

On 2017/12/2 1:15, Michal Hocko wrote:
> On Fri 01-12-17 17:58:28, Vlastimil Babka wrote:
>> On 11/30/2017 11:15 PM, akpm@linux-foundation.org wrote:
>>> From: zhong jiang <zhongjiang@huawei.com>
>>> Subject: mm/page_owner: align with pageblock_nr pages
>>>
>>> When pfn_valid(pfn) returns false, pfn should be aligned with
>>> pageblock_nr_pages other than MAX_ORDER_NR_PAGES in init_pages_in_zone,
>>> because the skipped 2M may be valid pfn, as a result, early allocated
>>> count will not be accurate.
>>>
>>> Link: http://lkml.kernel.org/r/1468938136-24228-1-git-send-email-zhongjiang@huawei.com
>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>> Cc: Michal Hocko <mhocko@kernel.org>
>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> The author never responded and Michal Hocko basically NAKed it in
>> https://lkml.kernel.org/r/<20160812130727.GI3639@dhcp22.suse.cz>
>> I think we should drop it.
> Or extend the changelog to actually describe what kind of problem it
> fixes and do an additional step to unigy
> MAX_ORDER_NR_PAGES/pageblock_nr_pages
>  
  Hi, Michal
   
        IIRC,  I had explained the reason for patch.  if it not. I am so sorry for that.
    
        when we select MAX_ORDER_NR_PAGES,   the second 2M will be skiped.
       it maybe result in normal pages leak.

        meanwhile.  as you had said.  it make the code consistent.  why do not we do it.
   
        I think it is reasonable to upstream the patch.  maybe I should rewrite the changelog
       and repost it.

    Michal,  Do you think ?

 Thanks
zhongjiang
>>> ---
>>>
>>>  mm/page_owner.c |    2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff -puN mm/page_owner.c~mm-page_owner-align-with-pageblock_nr-pages mm/page_owner.c
>>> --- a/mm/page_owner.c~mm-page_owner-align-with-pageblock_nr-pages
>>> +++ a/mm/page_owner.c
>>> @@ -544,7 +544,7 @@ static void init_pages_in_zone(pg_data_t
>>>  	 */
>>>  	for (; pfn < end_pfn; ) {
>>>  		if (!pfn_valid(pfn)) {
>>> -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
>>> +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>>>  			continue;
>>>  		}
>>>  
>>> _
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
