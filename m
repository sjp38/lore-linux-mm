Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30ED8C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:55:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C53F02087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:55:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C53F02087B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19D5B6B0003; Mon, 29 Apr 2019 07:55:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 125E66B0005; Mon, 29 Apr 2019 07:55:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE2B76B0007; Mon, 29 Apr 2019 07:55:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9DF6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:55:30 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u19so11635009wmj.5
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 04:55:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=c4DQQlMYpYLPNWy1jkTEOIN3Thpw5NnN0jol7sCodho=;
        b=jtrLucHKrMZIW3wdEBDeVbha4ZWPVZUZQV9ymDjIftxoQR/a2z2g3wD006+2BSLo7Z
         9IesrJnJRJ/1uZbmTWbHtufhHa9UwlBiz6M0AqknR5dKqSb2qpgk3Ip+SjF8NPk/a2SF
         xjQvFq7WTRdKjlhkii3ivg1xPWode54oLyXvOKn+8EoJACiU7RX5Ah2/Rb8kNPSQLDkB
         JGSBBjkwcoGx3hKQmWaQ6FVYw5KUJUZMy5/MuhAkHknqc+IiyOKfaiXitOhAUGw3X0l5
         XRYGCZh2XUpPFm7A117ZREn5gKxx5PtAWBkPE2eR/icBnnzGQ/EfDYVNIdJnvgCQrkHq
         n/Dg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Gm-Message-State: APjAAAXB6r20X9tcepJ2Qnqb83fLngEmOZZKm5z2Zhy6VrwoM1bVNmfz
	ebznL28tnCppQgjixNoRsawpsyR8tYJFpDbF4i4Ye02ecCr1lYTafLP05glHqyb74JMJ/GV7R7K
	mx9wOVmj16Gp3Q41Kx1tsC1spgkoX92MECwcCUR6935H90Nsdua0KZgpK5d0Q/90=
X-Received: by 2002:a05:6000:ca:: with SMTP id q10mr19276195wrx.148.1556538930242;
        Mon, 29 Apr 2019 04:55:30 -0700 (PDT)
X-Received: by 2002:a05:6000:ca:: with SMTP id q10mr19276168wrx.148.1556538929546;
        Mon, 29 Apr 2019 04:55:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556538929; cv=none;
        d=google.com; s=arc-20160816;
        b=bmOd5xcSIpU9oMZ6DwJFSrMF5QiRQFu1apOKjR+WC2gB3G2BU9gQzjkx0qQ0cJLtYx
         aFT2+MEKph8F7+/Y2AOXTG72IWJcHvJ8zII0Lw1Q36FUf6EaaeiVgHbdYUICFx3913uf
         GjO0Ab5vQOAWZHk5k4ltbZDIEcvUfyu3zr4dijhb/Xoe9gL3Bty4/6bg4uP38EhH8g7r
         /29W5G/8TRXJimFJvFugS/425tGLrKkb8BMcEwpS7j30Pi0OUXH3Rk5ASAcsX/OuoH9c
         273sLYdltG+5jiXAT5mLvZqYSlaF4mtILCYoQ0nypIlJBwlsn9O16Z0fQZ5h1PyDLsws
         1aLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=c4DQQlMYpYLPNWy1jkTEOIN3Thpw5NnN0jol7sCodho=;
        b=t3FB2PmDv79GF7nS/ycnlf+oVvkZ6XdnIBwxilWMz723utvKOyfnuGCFy7teHrN5N2
         SuzUStZFb2nZctzwMMgbD5oP39vdkm35tSWYCcbQinDCf1qSagE1ZyDMdi35KF8/qhyY
         ziSsb8lCw8l+9jzAiamIhW5bWWt69cB8AktP7/HpuByOngKiee6u6i452qxaNaWGsBUP
         bjBYgebyxJd4Kc1Z71Qdkqayhuax0fpqEUglJjZMfImUZ2wMwvsHOzKS5jlJEUR0bQCJ
         Gas/SAyQqhVu1xUEwAOifFqQJbYRRqXDUyjgCryv81qvXaJN4uBNC04psT50ZShaMVxJ
         5m2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v128sor17360649wme.7.2019.04.29.04.55.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 04:55:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Google-Smtp-Source: APXvYqx/22oAr8zW29ywyTAM4/CLNybWia5AhbVFjmxehnchgKx1c7pMfzhQ7qY/TMBZEFwTzqQgxQ==
X-Received: by 2002:a1c:1a85:: with SMTP id a127mr3302088wma.139.1556538929216;
        Mon, 29 Apr 2019 04:55:29 -0700 (PDT)
Received: from ?IPv6:2a0b:e7c0:0:107::49? ([2a0b:e7c0:0:107::49])
        by smtp.gmail.com with ESMTPSA id d11sm29364711wrc.32.2019.04.29.04.55.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 04:55:28 -0700 (PDT)
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
 <20190429112916.GI21837@dhcp22.suse.cz>
From: Jiri Slaby <jslaby@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=jslaby@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <465a4b50-490c-7978-ecb8-d122b655f868@suse.cz>
Date: Mon, 29 Apr 2019 13:55:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190429112916.GI21837@dhcp22.suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29. 04. 19, 13:30, Michal Hocko wrote:
> On Mon 29-04-19 12:59:39, Jiri Slaby wrote:
> [...]
>>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>>  {
>> -	/*
>> -	 * This needs node 0 to be always present, even
>> -	 * in the systems supporting sparse numa ids.
>> -	 */
>> -	return !!lru->node[0].memcg_lrus;
>> +	return !!lru->node[first_online_node].memcg_lrus;
>>  }
>>  
>>  static inline struct list_lru_one *
> 
> How come this doesn't blow up later - e.g. in memcg_destroy_list_lru
> path which does iterate over all existing nodes thus including the
> node 0.

If the node is not disabled (i.e. is N_POSSIBLE), lru->node is allocated
for that node too. It will also have memcg_lrus properly set.

If it is disabled, it will never be iterated.

Well, I could have used first_node. But I am not sure, if the first
POSSIBLE node is also ONLINE during boot?

thanks,
-- 
js
suse labs

