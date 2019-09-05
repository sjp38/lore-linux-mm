Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68916C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 23:11:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D89D20674
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 23:11:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KWATY8V7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D89D20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF64B6B0006; Thu,  5 Sep 2019 19:11:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA7106B0007; Thu,  5 Sep 2019 19:11:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B97DD6B0008; Thu,  5 Sep 2019 19:11:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1706B0006
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 19:11:58 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 39001181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 23:11:58 +0000 (UTC)
X-FDA: 75902416716.14.fire00_1120b19099026
X-HE-Tag: fire00_1120b19099026
X-Filterd-Recvd-Size: 5036
Received: from mail-lf1-f65.google.com (mail-lf1-f65.google.com [209.85.167.65])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 23:11:57 +0000 (UTC)
Received: by mail-lf1-f65.google.com with SMTP id l11so3416753lfk.6
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 16:11:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=rsv0Voxxp+ItU2AmdJliC6lRiDyJh5oUWnyootcl/es=;
        b=KWATY8V78X6WT4GPUKQJmVfGTCnU5vhDE/oaXa6aC1GLF2h5PoYpxaD4OLLdxTk1wb
         NRbBqJ+uBWEjMXtoulBYmFShow+CO7RWdA682IgebS0PjNMEt1MRtryBK8N9fscdt06B
         xBhyfc+9E8HXYbk9FJZ7CjwMY0BLIwCNByrsdn/9MCUsd3hQ4EkpfTpbz8deZMiF409a
         2EkQ2s0Jdg62I6PuiGOhfDm8O4BNqWZEyXu/rD4+BHpB8I0bipPUwnfZA6tz4izZ2S4F
         OgGxKeLePQc9Ei5o0/7ubCk3WSaTcEQb5s88aMjCTS6pBY4g9w48ztMf1dPdlohuukMM
         jb2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=rsv0Voxxp+ItU2AmdJliC6lRiDyJh5oUWnyootcl/es=;
        b=cGw82XLyO/wsBXjRi6sWUTRM+C4t/NYKKSDy6ofAg61Wb+AT8ojg7TK11peK9r9nkn
         sxLfi13h3jF3w4fJ/65ifXsOxDNgooi8inyYTQuTzSdS9GhgGXFh3CwcLV59b2X1qcLm
         NswUKe2w61LysN3P+cbwAf3NGP1vh/PMCDtAvx8lY4hfpxUeXYRtCR/plptorIDKShLG
         YbRCk5ThqUB65Kpqx5u5gEKK9UCdkLIyeg/j2POPd/r7AhrRl6/ZL/NBBpdBohqQcoPG
         Xeo3veOMjreGt3sLfQDYRkv8yjYNC9IE7BSzO1I4Qgx2hcLDQzyDx/8YZNhc5+2t6rdg
         Ioig==
X-Gm-Message-State: APjAAAXP5ZYU5dypAVStZTOiVg4pMxh4p8N/63TDGeUJ6uip1lmSJlvi
	YX/d9OXpszxOmWwfj4thvYNO/ix8SFU=
X-Google-Smtp-Source: APXvYqz6gFjjmfdcqN7f+AGnrw3zq8eQftPhMdIM9dJmaaEC3Q68LUa3et1MQfvpIV4wVuupkJfkhw==
X-Received: by 2002:ac2:5090:: with SMTP id f16mr4297861lfm.66.1567725115794;
        Thu, 05 Sep 2019 16:11:55 -0700 (PDT)
Received: from [84.217.164.5] (c-8caed954.51034-0-757473696b74.bbcust.telenor.se. [84.217.164.5])
        by smtp.gmail.com with ESMTPSA id p26sm705000lfc.25.2019.09.05.16.11.54
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 05 Sep 2019 16:11:55 -0700 (PDT)
Subject: Re: [BUG] kmemcg limit defeats __GFP_NOFAIL allocation
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Michal Hocko <mhocko@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <666dbcde-1b8a-9e2d-7d1f-48a117c78ae1@I-love.SAKURA.ne.jp>
 <ccf79dd9-b2e5-0d78-f520-164d198f9ca4@gmail.com>
 <4d0eda9a-319d-1a7d-1eed-71da90902367@i-love.sakura.ne.jp>
 <20190904112500.GO3838@dhcp22.suse.cz>
 <0056063b-46ff-0ebd-ff0d-c96a1f9ae6b1@i-love.sakura.ne.jp>
 <20190904142902.GZ3838@dhcp22.suse.cz>
 <405ce28b-c0b4-780c-c883-42d741ec60e0@i-love.sakura.ne.jp>
From: Thomas Lindroth <thomas.lindroth@gmail.com>
Message-ID: <16fdbf78-3cf4-81cf-2a73-d38cb66afc17@gmail.com>
Date: Fri, 6 Sep 2019 01:11:53 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <405ce28b-c0b4-780c-c883-42d741ec60e0@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/4/19 6:39 PM, Tetsuo Handa wrote:
> On 2019/09/04 23:29, Michal Hocko wrote:
>> Ohh, right. We are trying to uncharge something that hasn't been charged
>> because page_counter_try_charge has failed. So the fix needs to be more
>> involved. Sorry, I should have realized that.
> 
> OK. Survived the test. Thomas, please try.
> 
>> ---
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 9ec5e12486a7..e18108b2b786 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2821,6 +2821,16 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
>>   
>>   	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
>>   	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
>> +
>> +		/*
>> +		 * Enforce __GFP_NOFAIL allocation because callers are not
>> +		 * prepared to see failures and likely do not have any failure
>> +		 * handling code.
>> +		 */
>> +		if (gfp & __GFP_NOFAIL) {
>> +			page_counter_charge(&memcg->kmem, nr_pages);
>> +			return 0;
>> +		}
>>   		cancel_charge(memcg, nr_pages);
>>   		return -ENOMEM;
>>   	}
>>

I tried the patch with 5.2.11 and wasn't able to trigger any null pointer
deref crashes with it. Testing is tricky because the OOM killer will still
run and eventually kill bash and whatever runs in the cgroup.

I backported the patch to 4.19.69 and ran the chromium build like before
but this time I couldn't trigger any system crashes.

