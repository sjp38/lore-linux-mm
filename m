Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7227AC00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 15:06:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A6CF2070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 15:06:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e+UAEUh5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A6CF2070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 588AC6B026D; Thu,  5 Sep 2019 11:06:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 539A76B0270; Thu,  5 Sep 2019 11:06:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 427C76B0271; Thu,  5 Sep 2019 11:06:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0139.hostedemail.com [216.40.44.139])
	by kanga.kvack.org (Postfix) with ESMTP id 207BE6B026D
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:06:29 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B766D824CA21
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:06:28 +0000 (UTC)
X-FDA: 75901193256.16.crowd23_8fc8e98f6df06
X-HE-Tag: crowd23_8fc8e98f6df06
X-Filterd-Recvd-Size: 4237
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com [209.85.221.68])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:06:27 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id l16so3167194wrv.12
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 08:06:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=FUgWccw0woyG2e6M/7x469teGzAXAKjM5wym+f71oLU=;
        b=e+UAEUh5SHxW1D8bYZCGYrbModyU/OXU3yDAxz4voldJsEaZQEXtvsXWm7v+9pAkGF
         BJLTEX3dqNCBTw3qdGwjqLCbuLEUWwbYKZyfPDwt9GCwykySJwxjaUTa4ouNKatSzYd5
         rHct195PnDwraMfmIPVbFnRoRLla15Km3O20FqlIZSLWwLpKJr/IKyvy3WdIqGhtVVNp
         REu46XBQy4Ch90jVs9csNzj3+PiLgwZ6422f40CqfBdy7ZbucEcgsed1OYIi04xP7j3L
         Yu3b+6pcITEPKPoEHElO/hI8qe8GyIEit60LnC0rGRGmCOspPYitYB2bnsJpU8GryxgH
         YTeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=FUgWccw0woyG2e6M/7x469teGzAXAKjM5wym+f71oLU=;
        b=Az6ya/nYGaBnsRZ0SDlQbIg/88VLu6hDUum3K96Un3KPo8MGc6dISKXv17z0wEXgqd
         LOPlYdvyws2wBn5zkrgUZRUxqiFUYoAfR+S6nH5ZxXx3+UvzSzb+BCI1hZetlENaprQf
         0efdG2/FOH1hGeUM1O+tbog701uNXfIVApdnPO+FWDyXAFfOcw8W4nc2hjlavK+M7rmO
         bkbz6CVWnFV2tYpVwwUvCZxPRxfOFcp6y2PJzEfmd28SqfJFmqeHOGarmFE4GcjsxA+g
         rzLSX6V3zkSdvU6vbC4jPRMhPER+M8+LqrqthuxRaAOR5rr/8R1/eZKgGLPSEWvz8W2d
         ZZgQ==
X-Gm-Message-State: APjAAAVhQVfvEyYuALY7dmzHqPDbaygtzJc2b1sGMTrhsGOSvu8g0kuT
	O6Wd+FgoqPctSTKBcKzPVmI=
X-Google-Smtp-Source: APXvYqzOItE1cvzLVy+eSPRwJEMTk3j5+XdfCLAUzFZEoTLNy6oDpYOIt9n+79BqphySIrPpLua5gg==
X-Received: by 2002:a5d:4649:: with SMTP id j9mr2995539wrs.193.1567695986780;
        Thu, 05 Sep 2019 08:06:26 -0700 (PDT)
Received: from [192.168.8.147] (163.175.185.81.rev.sfr.net. [81.185.175.163])
        by smtp.gmail.com with ESMTPSA id z5sm2501262wrl.33.2019.09.05.08.06.24
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 05 Sep 2019 08:06:25 -0700 (PDT)
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
To: Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
 Michal Hocko <mhocko@kernel.org>, davem@davemloft.net,
 netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>
References: <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw> <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw> <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV> <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV> <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw> <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
 <165827b5-6783-f4f8-69d6-b088dd97eb45@gmail.com>
 <1567692555.5576.91.camel@lca.pw>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <5b4b16b1-caf9-ceff-43a4-635489d6ac66@gmail.com>
Date: Thu, 5 Sep 2019 17:06:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1567692555.5576.91.camel@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.030317, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/5/19 4:09 PM, Qian Cai wrote:
> 
> I feel like you may not follow the thread closely. There are more details
> uncovered in the last few days and narrowed down to the culprits.
> 

I have followed the thread closely, thank you very much.

I am happy that the problem is addressed as I suggested.
Ie not individual patches adding selected __GFP_NOWARN.


