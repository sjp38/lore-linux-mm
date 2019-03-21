Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 029A1C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:29:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF87D21900
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:29:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF87D21900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 488EA6B0003; Thu, 21 Mar 2019 19:29:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43A9F6B0006; Thu, 21 Mar 2019 19:29:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32B356B0007; Thu, 21 Mar 2019 19:29:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E692F6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 19:29:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f1so352746pgv.12
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:29:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=vjK9rfTb2V2JEeU1UvM17hsZzColp1atzGapWPaodi8=;
        b=SR7nbZ1sqnP7ifhf1RjedmbvHcuvd1coxcBiT3ZanJX5lVWDt53bABIbo7WiouyisT
         gBLKrhO2PgEpNGF/Lwy/ZU3J6MfdQpa3LLkpZ1FxfkmigS4JYb6MXgWmzwYr9Q0YI0Bh
         sdoMMd4Orw1ItKE2FTTVDnU+34TcanZu6V3XiMjyGcSeOxNugBmF1gWKY03eh+vgY98w
         1eKEQ+zM/BMpYkEnfy1U6LiaZ5ebaGhPiU/jN9Bl99SEFTtjkm3yv8COVdgGO8oMlUR9
         Vz3H9MBX7IcYRe5URUree9tHQfugyrdItWTWQ9assPlQQUZxy/cVR+O1EdqoLaLn0Jsq
         Z6rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXd+PI18tR2+IG9tODDZaUORlG7qbsbNVDwLQRWD3ReDc2tQXYc
	zes1E/MNw91vFyGiIOBDMOAPY6zRUbq89AXBir3o7+Qtf9cEOjNJckVuc5G8t+IN9u4Zsyk213p
	CjpIWB+ZzqTIPP8IRZgAMJtglfnF5ChIldEZirbCcl2QnxjViKxZrjRJdHvlWsK4jRA==
X-Received: by 2002:a62:a219:: with SMTP id m25mr5995822pff.197.1553210979613;
        Thu, 21 Mar 2019 16:29:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxu8p9uJ+m4BY3zuR45dxHpRISMQjwcbImomHvc5d2uuShBTJEjBNkWhou1YHEudfjXfds1
X-Received: by 2002:a62:a219:: with SMTP id m25mr5995786pff.197.1553210978821;
        Thu, 21 Mar 2019 16:29:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553210978; cv=none;
        d=google.com; s=arc-20160816;
        b=B7Zv5dcFGJ3C/knwc9PX/MpFBmXTCFXKVogT55FdoQpSUwp5Nimi7yEmwF24Qnqt8s
         dnJDLQYbTzMaAIptyB6KSV+TiUuqhQTGVgDTuhOESMGVhd6XJKoJV7X5MqH5Wg1iSWiC
         QvssJIZNDgd+OzvfD1gZIfGA7t2Ox7x5jZ1fpkdDzrpIsEyOnjldn3yu0EFv0vDJ567a
         owvp6C9h117ldna70/fHNSJme2IlkDC6zb/jr1h03vOdtMoV/Ye6TiD0hpxrcHn2LK2N
         AdMhx1GIpqRX5GklLvcYamF3ifx7Pb5SX6ULXGLmA5SIXzx1pnVN161gtQV2NDjk7zIo
         MniQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=vjK9rfTb2V2JEeU1UvM17hsZzColp1atzGapWPaodi8=;
        b=ppmY/1NvCxNlaJfEixdgC2Iyru0edw9Tv2LFm5Q9VKS+z0cLnyXLpg/SpzE1rilyeF
         Bf1k0pZTigco41tuzXsvkxfnrp+72lP2/HGmsBADcTtZiad+ThGhcUB9w5qQXQRcATIU
         4p+5JmgG+0U/69yyy0GxgLsis49KaSWoKEfO29YvCBmL0beugnxzZnqRwIjM2FXcVgEm
         k2XMWgQtOGUswncrHdyu/upjReUHGwe0KpPtU9qJ6MXf7+GAB6tEkDISjabQ1ub8ko9m
         kYGJjzXjnEjTUhzS8DNeVD2/gm9YDY8mE+q/4zHpEUF7wFy1xRvUj43FdQ7CIxuCSJaL
         lFsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id k86si5385497pfj.145.2019.03.21.16.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 16:29:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04427;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TNJJXe4_1553210974;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNJJXe4_1553210974)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 22 Mar 2019 07:29:36 +0800
Subject: Re: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, vbabka@suse.cz,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190321145745.GS8696@dhcp22.suse.cz>
 <75059b39-dbc4-3649-3e6b-7bdf282e3f53@linux.alibaba.com>
 <20190321165112.GU8696@dhcp22.suse.cz>
 <60ef6b4a-4f24-567f-af2f-50d97a2672d6@linux.alibaba.com>
 <20190321192403.GF3189@techsingularity.net>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <504618a2-3214-5f25-5d59-2aee629a9ff1@linux.alibaba.com>
Date: Thu, 21 Mar 2019 16:29:32 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190321192403.GF3189@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/21/19 12:24 PM, Mel Gorman wrote:
> On Thu, Mar 21, 2019 at 10:25:08AM -0700, Yang Shi wrote:
>>
>> On 3/21/19 9:51 AM, Michal Hocko wrote:
>>> On Thu 21-03-19 09:21:39, Yang Shi wrote:
>>>> On 3/21/19 7:57 AM, Michal Hocko wrote:
>>>>> On Wed 20-03-19 08:27:39, Yang Shi wrote:
>>>>>> MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
>>>>>> MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
>>>>>> mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
>>>>>> right away in 2012.  So, it is never ever exported to userspace.
>>>>>>
>>>>>> And, it looks nobody is interested in revisiting it since it was
>>>>>> disabled 7 years ago.  So, it sounds pointless to still keep it around.
>>>>> The above changelog owes us a lot of explanation about why this is
>>>>> safe and backward compatible. I am also not sure you can change
>>>>> MPOL_MF_INTERNAL because somebody still might use the flag from
>>>>> userspace and we want to guarantee it will have the exact same semantic.
>>>> Since MPOL_MF_LAZY is never exported to userspace (Mel helped to confirm
>>>> this in the other thread), so I'm supposed it should be safe and backward
>>>> compatible to userspace.
>>> You didn't get my point. The flag is exported to the userspace and
>>> nothing in the syscall entry path checks and masks it. So we really have
>>> to preserve the semantic of the flag bit for ever.
>> Thanks, I see you point. Yes, it is exported to userspace in some sense
>> since it is in uapi header. But, it is never documented and MPOL_MF_VALID
>> excludes it. mbind() does check and mask it. It would return -EINVAL if
>> MPOL_MF_LAZY or any other undefined/invalid flag is set. See the below code
>> snippet from do_mbind():
>>
> That does not explain the motivation behind removing it or what we gain.
> Yes, it's undocumented and it's unlikely that anyone will. Any potential
> semantics are almost meaningless with mbind but there are two
> possibilities. One, mbind is relaxed to allow migration within allowed
> nodes and two, interleave could initially interleave but allow migration
> to local node to get a mix of average performance at init and local
> performance over time. No one tried taking that option so far but it
> appears harmless to leave it alone too.

Yes, actually this is what I argued, no one tried taking the flag for 
long time. I also agree it sounds harmless to leave it. I just thought 
it may be dead code, if so why not just remove it.

Thanks,
Yang

>

