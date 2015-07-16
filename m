Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 17CA22802E6
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 22:23:50 -0400 (EDT)
Received: by padck2 with SMTP id ck2so33915002pad.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:23:49 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id pf6si10405270pbb.67.2015.07.15.19.23.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Jul 2015 19:23:49 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 16 Jul 2015 07:53:45 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id BDDB91258056
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 07:56:38 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6G2NgVc40763616
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 07:53:42 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6G2Ng8N003542
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 07:53:42 +0530
Date: Thu, 16 Jul 2015 10:23:40 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memblock: WARN_ON when flags differs from overlap
 region
Message-ID: <20150716022340.GA13777@richard>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1436342488-19851-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1436588376-25808-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1507151719230.9230@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507151719230.9230@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Wed, Jul 15, 2015 at 05:19:39PM -0700, David Rientjes wrote:
>On Sat, 11 Jul 2015, Wei Yang wrote:
>
>> Each memblock_region has flags to indicates the Node ID of this range. For
>> the overlap case, memblock_add_range() inserts the lower part and leave the
>> upper part as indicated in the overlapped region.
>> 
>
>Memblock region flags do not specify node ids, so this is somewhat 
>misleading.
>

Thanks for pointing out, the commit message is not correct.

It should be "type" instead of "Node ID".

>> If the flags of the new range differs from the overlapped region, the
>> information recorded is not correct.
>> 
>> This patch adds a WARN_ON when the flags of the new range differs from the
>> overlapped region.
>> 
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> ---
>>  mm/memblock.c |    1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 95ce68c..bde61e8 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -569,6 +569,7 @@ repeat:
>>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>>  			WARN_ON(nid != memblock_get_region_node(rgn));
>>  #endif
>> +			WARN_ON(flags != rgn->flags);
>>  			nr_new++;
>>  			if (insert)
>>  				memblock_insert_region(type, i++, base,

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
