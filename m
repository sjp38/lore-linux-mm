Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A6FEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:29:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E32422229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:29:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E32422229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 788038E0002; Thu, 14 Feb 2019 05:29:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 736248E0001; Thu, 14 Feb 2019 05:29:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64D2F8E0002; Thu, 14 Feb 2019 05:29:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED2028E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:29:05 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id z71so1445425ljb.18
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:29:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=F9dSxXVsEsq9XO7H9YUx5kISSCmpjxuhQeaOi59KI5Q=;
        b=jU+coWl3XJn43AmFEQPmsWs/RErFZdogOThSbH6gpc8dpart0maEfyyW4yRlh4gk1Y
         Ir0VfQ5SnB/yBw6C93D4Zil0TuMVanSzA/xDlsEumxaw4OMc7v/LmQOrzCitfR2WVb4i
         omf3Run+XmG+Il1KeeE/BPbwdaT5kqDgqR4tIII9K+AEKmgJ9rEWEHSchO595uFMTZU/
         V2gA2qSheLHnaz6qO20i0zOp08HHHOSVqhUV5++lFUe0QOH6LpdQPxTja8y4vd87d1nE
         XxgQz9Hr9UEZccVClc0AjZpfzUYKqAQNLn65InpTcQ5gkGoQU7+2QEofs1iIlWM19DzY
         AFAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuaddQpwpVpoPbU0lvAp9siUih3YXT1gE6Nm3WOllG6lBZDhSGUk
	ITwVSHCZmfS3IhatAQG6f8lr1my/AlIJCoqe7K0AYXTCRIuj9e85Xu5+KTIGWdKpgmzI9sVcXZm
	UFIvS0cxP1ZvijJrxBvn5lUtlvn5g0dnAggwpbkhEsovKKFS3ytCHd7c3rB3QT3GHSw==
X-Received: by 2002:a2e:3a10:: with SMTP id h16-v6mr1938110lja.184.1550140145290;
        Thu, 14 Feb 2019 02:29:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ498vogEIhL0HLKX+dj132lBn7TMBtosn86G5w93htjSEA9o9SagVtOq+TqvCrAK93XQhM
X-Received: by 2002:a2e:3a10:: with SMTP id h16-v6mr1938065lja.184.1550140144386;
        Thu, 14 Feb 2019 02:29:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140144; cv=none;
        d=google.com; s=arc-20160816;
        b=Lor1CQrwOFOFL6aSkyCM/3eSSbsQeobKy9PrRbZGM5BXBXVbCcH3j9b4aSsi2Df2Je
         lL158fRGOyCH/sMuQCbMUBm5T6hqTYN7RPl0NgKoLvOx+27pqNq8hUONGU4qUrkbJ7TG
         Y8Pm5nQ/PWEqqS1yCAKaiUFz4WF+oRvTDDyMC5MskWMVCPBNGPftMxVtikdbuE35fElD
         aApoIEZV2AOnBQuWtOzMsv3M8EqnNQ8rApfamDFFATsnLCU5AQT9Q9FqQ+QpMjlL9Nfr
         kOxnJ2Pv5HH4Kjlr/m8pFybpJnuSiNmBUCbfzfHutS0j+NFegPPiTuJFwDoB8zmAZskn
         fL+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=F9dSxXVsEsq9XO7H9YUx5kISSCmpjxuhQeaOi59KI5Q=;
        b=CWhMLWPhGSdd5vQb0jCx1j5gT/AI83h3qaJCCPCxaY4lqUx3brATzgdy6BpGxd34kB
         Qerc58mfp5NDm4vN/cGyTiZPCXu9c5UK4ex62ccNfI/B4vWTmwbs3xm2VwDrqUQjevyY
         /ffbLHY9qv47BQ797bcxIGy+o0w4lgJ96iqdjo7aiSKWR1sYtRYA6e0DEXvtuZYGLKaC
         K9UuGQG295Qgs/QOHaBCkNQrzWHDv/MBJY56L9y04emCMcSMQus00lXLGogUp+57vwRb
         hfJnrRLmcL7a7+ET8atpwjzGdE8h3/zJihYCDn+ctMtry8Xyjo7PU5AaiZCrRsMx6/Ou
         kP/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l5si1337376ljj.84.2019.02.14.02.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:29:04 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guEGN-00050x-1u; Thu, 14 Feb 2019 13:29:03 +0300
Subject: Re: [PATCH 4/4] mm: Generalize putback scan functions
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
 <154998445694.18704.16751838197928455484.stgit@localhost.localdomain>
 <20190213192011.62vmk5wyvxufcn4k@ca-dmjordan1.us.oracle.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <0add6f90-371d-c95b-7032-49f323f96b02@virtuozzo.com>
Date: Thu, 14 Feb 2019 13:29:01 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213192011.62vmk5wyvxufcn4k@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.02.2019 22:20, Daniel Jordan wrote:
> On Tue, Feb 12, 2019 at 06:14:16PM +0300, Kirill Tkhai wrote:
>> +static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
>> +						     struct list_head *list)
>>  {
>>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>> +	int nr_pages, nr_moved = 0;
>>  	LIST_HEAD(pages_to_free);
>> +	struct page *page;
>> +	enum lru_list lru;
>>  
>> -	/*
>> -	 * Put back any unfreeable pages.
>> -	 */
>> -	while (!list_empty(page_list)) {
>> -		struct page *page = lru_to_page(page_list);
>> -		int lru;
>> -
>> -		VM_BUG_ON_PAGE(PageLRU(page), page);
>> -		list_del(&page->lru);
>> +	while (!list_empty(list)) {
>> +		page = lru_to_page(list);
>>  		if (unlikely(!page_evictable(page))) {
>> +			list_del_init(&page->lru);
>>  			spin_unlock_irq(&pgdat->lru_lock);
>>  			putback_lru_page(page);
>>  			spin_lock_irq(&pgdat->lru_lock);
>>  			continue;
>>  		}
>> -
>>  		lruvec = mem_cgroup_page_lruvec(page, pgdat);
>>  
>> +		VM_BUG_ON_PAGE(PageLRU(page), page);
> 
> Nit, but moving the BUG down here weakens it a little bit since we miss
> checking it if the page is unevictable.

Yeah, this is bad.
 
> Maybe worth pointing out in the changelog that the main difference from
> combining these two functions is that we're now checking for !page_evictable
> coming from shrink_active_list, which shouldn't change any behavior since that
> path works with evictable pages only.

Sounds good.

