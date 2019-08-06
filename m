Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 105F0C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:36:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3E7720B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:36:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3E7720B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66A1D6B0283; Tue,  6 Aug 2019 05:36:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61EC96B0284; Tue,  6 Aug 2019 05:36:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ED146B0285; Tue,  6 Aug 2019 05:36:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 029596B0283
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:36:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so53416116edc.17
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:36:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WjVNe2F3OQqP8hJUCG4PYhkJJ017ssBHh7IEW0bHEE0=;
        b=pHT0Cyoes95SR5X2cI+LI4cz56w2BOA7WAHPfgJuimbTmbg51uwMObfTSDz9YUGP/m
         xDKb52v4EaeKavwnkctZEt4jjizgndAthvduxWNxi7DzFlTEMalc/Y2pnSGDCPiRgUth
         SQxyt3cXmA7TOx5EDL7Umv4G/KyaE0ZwIBm9fivkkNVJctKctV8ZSzgjzZoGb1N8QXfz
         Lgup+P1lb62mU4/o7/wU9bdRuXFECl0sJI0bOWc4z0AL6hgi+Bw6f2Co4DDOb/1eXknV
         2PoU4L269fGphdqeq0Irdp5erlD/mvy0qhg+IQ43pRgZ21+uDoM2R7nbiwalp5ryEPJT
         vk+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV6SidCrx4C/sTQjYlZZxEuTz2KDXaWo1JmPOP1aekEEVtRYCyN
	a8lrJdPioLz598FRCPStwR/t6hq7YMaRAPXZP0bV9iuSFe8igkzi/JF0acJtMaaAmaToxmv6zyT
	R1AKU6v4U5AEwMAamjJ3P2VVUoNyu9MhkFsNwtcW+sgU6OkcTUjcOuPOy8lfVrrfI9w==
X-Received: by 2002:a17:906:2797:: with SMTP id j23mr2178057ejc.50.1565084210579;
        Tue, 06 Aug 2019 02:36:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLU69/5Dym4Uo+/6NHuz64K3RELQvgjxDy9ba9nRIIDPx8MbFlviSGd0Dz7sjsmd0ewLsL
X-Received: by 2002:a17:906:2797:: with SMTP id j23mr2178026ejc.50.1565084209829;
        Tue, 06 Aug 2019 02:36:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565084209; cv=none;
        d=google.com; s=arc-20160816;
        b=S2FER6uZJDPSTpUMcSOwpzCIZRpfQk6GsJx7oYivee2r0QZRClrOB3ewZEuJd1aKTw
         0iRjNwPK2IdJTWqYB/v9ILVAKrZrJzph5u0SvSHk+OQ1RU15bTSsq5GTU08xYS8ZfgzH
         3O04e23SNtlgReogFQlh6YX/AxlF/FjBxfGE+3AjyCXPVWiUMVhkv8l46589yy9FqC6A
         dYI0W4D8S+/OpmPd1lJUp+9qg444FYs4j3ATqqOW0ruhSjqGyHPu0sQu+1vkGOreR0sW
         Vq5tVusbKdRN6o4PVTriZbKSDf/ZL76jckoL40mBtbgShYFsIKDQDa9eE7EDL/FOPADn
         YjRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WjVNe2F3OQqP8hJUCG4PYhkJJ017ssBHh7IEW0bHEE0=;
        b=az5XwabBAG+c43BdqgbUlwi2x40mVAMJrozhClSiBwg79RCBYyOOHIUnnnf49KRcSm
         C+IICFfqXxy1tRu+0vfE1wiPUU4qm+/XbFaGJRg5hIS0D6oca1IeXpgu8uP9mcMsSMQ6
         TT+UW/JbQ+1IHFsXAAQt7Xnmgcv/mi/6tH2RK+gHVVodMqjoDRkpsdnRuB1Ae7czq6oB
         vHL4KoUhgeFXI9vBBpLtuazc2T1E3btde/anKtZGQ6xPOckoDGB0vowpPw5Pd9sE6gpt
         /dH5gO9Pb5b6TGjyMLOMwpBCwNZ43tVqMdrUB3/T8tGEP9BbxtM06BqWqCEW0dJzh3XY
         LHxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c37si31521753edb.308.2019.08.06.02.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 02:36:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2BE57AE2E;
	Tue,  6 Aug 2019 09:36:49 +0000 (UTC)
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Suren Baghdasaryan <surenb@google.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Cc: "Artem S. Tashkinov" <aros@gmx.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
Date: Tue, 6 Aug 2019 11:36:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 3:08 AM, Suren Baghdasaryan wrote:
>> @@ -1280,3 +1285,50 @@ static int __init psi_proc_init(void)
>>         return 0;
>>  }
>>  module_init(psi_proc_init);
>> +
>> +#define OOM_PRESSURE_LEVEL     80
>> +#define OOM_PRESSURE_PERIOD    (10 * NSEC_PER_SEC)
> 
> 80% of the last 10 seconds spent in full stall would definitely be a
> problem. If the system was already low on memory (which it probably
> is, or we would not be reclaiming so hard and registering such a big
> stall) then oom-killer would probably kill something before 8 seconds
> are passed.

If oom killer can act faster, than great! On small embedded systems you probably
don't enable PSI anyway?

> If my line of thinking is correct, then do we really
> benefit from such additional protection mechanism? I might be wrong
> here because my experience is limited to embedded systems with
> relatively small amounts of memory.

Well, Artem in his original mail describes a minutes long stall. Things are
really different on a fast desktop/laptop with SSD. I have experienced this as
well, ending up performing manual OOM by alt-sysrq-f (then I put more RAM than
8GB in the laptop). IMHO the default limit should be set so that the user
doesn't do that manual OOM (or hard reboot) before the mechanism kicks in. 10
seconds should be fine.

