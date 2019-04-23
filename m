Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74A04C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:50:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E58812148D
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:50:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E58812148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.ee
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 775776B000C; Tue, 23 Apr 2019 12:50:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FC9F6B000D; Tue, 23 Apr 2019 12:50:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EB346B000E; Tue, 23 Apr 2019 12:50:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13A146B000C
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:50:04 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m85so2486229lje.19
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:50:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cjoCHyoIC2yeuXJSgWfOX23NNQ44eDLegGrThAODW9c=;
        b=ei4WeSHpFXep2dbiEQSu2vHoJ+D4lJyUmL+Q8XZhYD58Lh7mu24LHdGhXz7L3yelEm
         N4sqHobhMzuG3q30Y5aj87KPgc2UhKbSLmJ9fUNf7yixJL92w5y6vETAQlLPJiktSlr6
         dhVvuBDi97eSVCPohuG4CHdWm94yphSjtSz2PFxnPOcCJq5JfdY1a+qBLOApQl2kxmOH
         Qa3trZgGsFGE6Nhm81LSsPSPi6f56KkrcxEYfuFRzoiM8r8VqTFDFXpwVgW2+8PADaUB
         6Du/jcWJainb7YboyJlUAfiNWcgTjXR43X+F+XRFm1WIgCdJE62LVhxo6f4Q1/gSBMRV
         jfyg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
X-Gm-Message-State: APjAAAUXGZg+MC99X1ia18xhtfBr23YT9nNy4PR/ZzT1Mr9g6NkvIdDr
	uMQqjc9FeGDAEs20c05y3hhce4sSifbILSIPswG7EhaGZ4VTZlDRdM4HYhe/TKjpwtwaz0R9fXw
	6hrCD8HMQNrLYvwaIIhw8zi00xSkn2PTBoxDCim0egjd6GQXiNatiTDggoeVE+ek=
X-Received: by 2002:a2e:910b:: with SMTP id m11mr14201639ljg.14.1556038203468;
        Tue, 23 Apr 2019 09:50:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8tCOAMts1bJfbjfZiYgrASKrz6QCkkbRfW40qX0I2dwvE+Ha9i94zZPH96lOHjqb998GI
X-Received: by 2002:a2e:910b:: with SMTP id m11mr14201584ljg.14.1556038202602;
        Tue, 23 Apr 2019 09:50:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556038202; cv=none;
        d=google.com; s=arc-20160816;
        b=bCaX5J29qCCe0q5WbbAlJbXAbomfpRo2ycRfGx4ZqAFWWQcahnKYEpDdEs44MeEveo
         R0FsbdaMonK+pJsB/1+dFGGopTsoRL6U17zR1yaAurFZP04jl7nfxYRZ4eBcSE0e6wYU
         LFMr247ukY5O3BOF7UfvpdHdZ/yMSGWa+q8LdbER4xCkawKu9RgYlw3g0uQzI8eoS+/D
         8J3dfCMFEBMn4uIjjFwrOkOIfXpfH25OZh3bUZIpRYhy7eEgxE/+QmPjr0QGkk9fD2PZ
         UOGSdS/Ev+3RTrLoMcf/dHNlR5fGmowHaPAOcQ2WC0Azqvt+MJPnvN1Z4T4Cr7z/G0S7
         0Jdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cjoCHyoIC2yeuXJSgWfOX23NNQ44eDLegGrThAODW9c=;
        b=IH2X8RTfXq9CZCjlrkUqgLo5abTVJy8MK9CFB2ViNo9UzsFT3/G8r/hSZah5+d5U8U
         w9b3fAbY9vj8Yt3useqjldYw2b3GHwP5EPL3AZoyXOjIVv0lHti6y4Nfepgt1OdhNw2M
         hnE5VS9qBipXrmD3nnJDMNKy6ohZCRNDGTEAYjZyWyERAsVu5/OyeLTQ+a0eqRwX1Ey0
         v90gCKpLfHNDDRknqz4yMspCjGpKKtvx6P6SQxxoHMmgsdpCT8my4YKztGvSlcPYLfUW
         3hF48zxo1ic4SMLxADWgEMEcYy052qi3SW3qJrRHTd0ewJmR0RTckcLdVbeQM+3CuuYY
         eRuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id m12si7958573lfk.107.2019.04.23.09.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:50:02 -0700 (PDT)
Received-SPF: neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) client-ip=193.40.6.72;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Subject: Re: DISCONTIGMEM is deprecated
To: Christopher Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mikulas Patocka <mpatocka@redhat.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 linux-parisc@vger.kernel.org, linux-mm@kvack.org,
 Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
 linux-arch@vger.kernel.org
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com>
From: Meelis Roos <mroos@linux.ee>
Message-ID: <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee>
Date: Tue, 23 Apr 2019 19:49:57 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>> ia64 (looks complicated ...)
> 
> Well as far as I can tell it was not even used 12 or so years ago on
> Itanium when I worked on that stuff.

My notes tell that on UP ia64 (RX2620), !NUMA was broken with both
SPARSEMEM and DISCONTIGMEM. NUMA+SPARSEMEM or !NUMA worked. Even
NUMA+DISCONTIGMEM worked, that was my config on 2-CPU RX2660.

-- 
Meelis Roos

