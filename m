Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 665906B02C3
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:28:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d8so7567389pgt.1
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 14:28:42 -0700 (PDT)
Received: from out0-206.mail.aliyun.com (out0-206.mail.aliyun.com. [140.205.0.206])
        by mx.google.com with ESMTPS id 33si1928832plk.494.2017.09.20.14.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 14:28:41 -0700 (PDT)
Subject: Re: [PATCH 1/2] tools: slabinfo: add "-U" option to show
 unreclaimable slabs only
References: <1505934576-9749-1-git-send-email-yang.s@alibaba-inc.com>
 <1505934576-9749-2-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.10.1709201343320.97971@chino.kir.corp.google.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <58f316bb-8e2a-1854-70b5-36e87f95f96e@alibaba-inc.com>
Date: Thu, 21 Sep 2017 05:28:33 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1709201343320.97971@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/20/17 1:45 PM, David Rientjes wrote:
> On Thu, 21 Sep 2017, Yang Shi wrote:
> 
>> diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
>> index b9d34b3..9673190 100644
>> --- a/tools/vm/slabinfo.c
>> +++ b/tools/vm/slabinfo.c
>> @@ -83,6 +83,7 @@ struct aliasinfo {
>>   int sort_loss;
>>   int extended_totals;
>>   int show_bytes;
>> +int unreclaim_only;
>>   
>>   /* Debug options */
>>   int sanity;
>> @@ -132,6 +133,7 @@ static void usage(void)
>>   		"-L|--Loss              Sort by loss\n"
>>   		"-X|--Xtotals           Show extended summary information\n"
>>   		"-B|--Bytes             Show size in bytes\n"
>> +		"-U|--unreclaim		Show unreclaimable slabs only\n"
>>   		"\nValid debug options (FZPUT may be combined)\n"
>>   		"a / A          Switch on all debug options (=FZUP)\n"
>>   		"-              Switch off all debug options\n"
> 
> I suppose this should be s/unreclaim/Unreclaim/
> 
>> @@ -568,6 +570,9 @@ static void slabcache(struct slabinfo *s)
>>   	if (strcmp(s->name, "*") == 0)
>>   		return;
>>   
>> +	if (unreclaim_only && s->reclaim_account)
>> +		return;
>> +		
>>   	if (actual_slabs == 1) {
>>   		report(s);
>>   		return;
>> @@ -1346,6 +1351,7 @@ struct option opts[] = {
>>   	{ "Loss", no_argument, NULL, 'L'},
>>   	{ "Xtotals", no_argument, NULL, 'X'},
>>   	{ "Bytes", no_argument, NULL, 'B'},
>> +	{ "unreclaim", no_argument, NULL, 'U'},
>>   	{ NULL, 0, NULL, 0 }
>>   };
>>   
> 
> Same.
> 
> After that:
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Also, you may find it better to remove the "RFC" tag from the patchset's
> header email since it's agreed that we want this.

Thanks, will get fixed in v4.

Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
