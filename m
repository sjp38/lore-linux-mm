Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39639C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:19:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0043521773
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:19:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0043521773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BB356B0007; Tue, 16 Apr 2019 17:19:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86A2B6B0008; Tue, 16 Apr 2019 17:19:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 781126B000A; Tue, 16 Apr 2019 17:19:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 269F96B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 17:19:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e6so11630587edi.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:19:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BqbwlkcwKKq8GrJuUU/dA/6IkLCXIIR81ALNcKggwJ4=;
        b=IX616N8yj8jPVRjNJOXdX9HJw58RJf1GvHReaKjOQuE8mNzmcN5+fL12UGsiEcy0ro
         3n1eiRvW2Em0IjBhjmq1VDbFpZaSGhdqiefLELZpmHfJnr9neAuIGx5DcYqN25SLn6bv
         Rz626BrOYiJFDvgqqKLSYvmFMSAOC+a4VHCiq9+Uqn8eJdeDRT92QogIx/l71YIIOu3s
         pUdRSd9dO7JY+RBa/5iNK1LHMxad4H10lL1uIBzjxqlRPgYgC3wUNbnkoDrd17NVcDOi
         eKDQks3TN+7eEUcGZdqUCqdOwDk6L846/3zk87ERFpuN0dRD3Xcg29cznPH7rcfYateT
         VUUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXkiMjo8rBSXCnMJ8d5C71SEy2aLzgYvEzHIw+HGxVyKzT5wnBZ
	OCDF89FwdGRf3tR4Sqi9NfUYPLWfkiuOXuk67H1CUs6rANtLdtATqXkqp4giTNnHUeHJ3Arfzi4
	KQq6NNlrbElNB40w0mj9XweJOL1He9EgM/CGTDZrQjUN9TR0oqCwDICgBYgQDrd/Nvg==
X-Received: by 2002:aa7:c88b:: with SMTP id p11mr45073418eds.79.1555449569695;
        Tue, 16 Apr 2019 14:19:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwzuu4WOayC14WGG7+XlEvYhFnjEWdtEZFO3up6KV/bSuxo2cbEb4Ul+1nAKw6YxQsLdzE
X-Received: by 2002:aa7:c88b:: with SMTP id p11mr45073375eds.79.1555449568906;
        Tue, 16 Apr 2019 14:19:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555449568; cv=none;
        d=google.com; s=arc-20160816;
        b=o/NQcvaPBEo9jc+Sa3r6IqXG+mpzIr1No09f/dK1J6nMqT6reHYZki7wh9WvpeSoJA
         Ku1Jeafyqae6GnXEeS8mLPPWZQvYR9tQIym2eU8bI4nRIgLjtXYkE7ehryDWDOQvG7e+
         HQTkK93ryQQs1QdYYYgcAr7icDCz2ieOPctLgayhUc54sAGn7kMFBHH+OUML1yffdG0W
         uy4+w8bsBaUZRQGXeLi5Q9zqyTFaeATQBxHQhfjR2Am30Grlfc2tNv310NjsFjO6weBP
         ZSOJy2v6XtxHvLLHJElOwYttpdIAp7GxWfm2WET3Osn94R+qkFjvBw+KLxmqmQ7agpqv
         rqbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BqbwlkcwKKq8GrJuUU/dA/6IkLCXIIR81ALNcKggwJ4=;
        b=zPV6TPspGSU3g++hzcRpNEDTVetcoiAVWo1ctL+W5XF5l+tv0iPoZ5AmnVLNzqCtce
         le8L7wljzrLtrAl0ThMJQkMFLsl9oVrpIev8z+wO1o6C/UXFGl9A9Jo1feXT76iifoK9
         dhDZIJtifjRQe0h0Lxowx8k6KOkBrQSmiE6tiOvDDCDFU/9v1JtOCX3wu/0tnlW13W6v
         WSHvi9T24Rla1G2C0OcvpflLzFLaR5Lx/3ZoWW8ItCNuKGwklzKwwtL5K5cb5dmAkrO+
         nZ2DdqugOOGD1Zgixt3rJpQ1PE8ba37deLLpsMcUuZGE/Qx7COTccaS2bEKvLn1Xcj+9
         04uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx19si2401482ejb.350.2019.04.16.14.19.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 14:19:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DE1EAAC1B;
	Tue, 16 Apr 2019 21:19:27 +0000 (UTC)
Subject: Re: [PATCH] slab: remove store_stackinfo()
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, luto@kernel.org,
 jpoimboe@redhat.com, sean.j.christopherson@intel.com, penberg@kernel.org,
 rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190416142258.18694-1-cai@lca.pw>
 <902fed9c-9655-a241-677d-5fa11b6c95a1@suse.cz>
 <alpine.DEB.2.21.1904162040570.1780@nanos.tec.linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <235d7500-8235-c7d4-0d6f-4d069133bd8d@suse.cz>
Date: Tue, 16 Apr 2019 23:19:11 +0200
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1904162040570.1780@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/16/2019 8:50 PM, Thomas Gleixner wrote:
> On Tue, 16 Apr 2019, Vlastimil Babka wrote:
> 
>> On 4/16/19 4:22 PM, Qian Cai wrote:
>>> store_stackinfo() does not seem used in actual SLAB debugging.
>>> Potentially, it could be added to check_poison_obj() to provide more
>>> information, but this seems like an overkill due to the declining
>>> popularity of the SLAB, so just remove it instead.
>>>
>>> Signed-off-by: Qian Cai <cai@lca.pw>
>>
>> I've acked Thomas' version already which was narrower, but no objection
>> to remove more stuff on top of that. Linus (and I later in another
>> thread) already pointed out /proc/slab_allocators. It only takes a look
>> at add_caller() there to not regret removing that one.
> 
> The issue why I was looking at this was a krobot complaint about the kernel
> crashing in that stack store function with my stackguard series applied. It
> was broken before the stackguard pages already, it just went unnoticed.
> 
> As you explained, nobody is caring about DEBUG_SLAB + DEBUG_PAGEALLOC
> anyway, so I'm happy to not care about krobot tripping over it either.
> 
> So we have 3 options:
> 
>    1) I ignore it and merge the stack guard series w/o it
> 
>    2) I can carry the minimal fix or Qian's version in the stackguard
>       branch
> 
>    3) We ship that minimal fix to Linus right now and then everyone can
>       base their stuff on top independently.

I think #3 is overkill for something that was broken for who knows how long and
nobody noticed. I'd go with 2) and perhaps Qian's version as nobody AFAIK uses
the caller+cpu as well as the stack trace.

For Qian's version also:
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> #3 is probably the right thing to do.
> 
> Thanks,
> 
> 	tglx
> 

