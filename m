Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AABEFC43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 06:09:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 307A2206E0
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 06:09:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gPOXauLn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 307A2206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE4926B0007; Sun, 28 Apr 2019 02:09:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B94536B0008; Sun, 28 Apr 2019 02:09:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A84366B000A; Sun, 28 Apr 2019 02:09:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 830AE6B0007
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 02:09:04 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k8so6425867qkj.20
        for <linux-mm@kvack.org>; Sat, 27 Apr 2019 23:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6wTH00IEcec2nG40s34dkAdJONtpHNStLOW3P3TBn8g=;
        b=SNGmruqmjsI7zjBPJHVL8BuGXSKwKlCZEZ/ZmBq5cMKT9VgVvNqlk34N3Q0N8jdkTr
         rAh987Rej8/GxClxfHXL3pT/BB5fzo9xWCPJMwXfTvayIBIdmFkFqt9cvSWttZui56oo
         6ySaFTg7SM1kXEgDf55EUpVh5PslNyEv60GPNlZaNMZytnePj577x+oIc+fZkIEDP/5b
         kXZpmDMsoI/kFs49/COJ2sXZkhCCdU8uTCgcgGkEmy5MrU0SHo+wrGuXs/KKgbZWxwza
         6gh08+LZaUlW2E68UY9OBEMqcyIfVB2kcOwqaKKclZ7AaNZ0/Ce/qCaiSPyZ4K7vTqgf
         ZBbw==
X-Gm-Message-State: APjAAAUTy2GMjLFZbE5q79hrRrOTy86EsMOXiRyT8UAjbDIPpdJrDjaG
	r2BxzfghhASY3yZEB+dNuhmIpDg7RPUdLSGobKwcQlmpsHi+zDu7lyYXHsXFZ1H/vGKSpdbuCvN
	oFcLjEGmPjwd51KVExPpTEii5XuAgjfPz3MPf8u/7TgczRr/0N7KQgDP8By85180=
X-Received: by 2002:a0c:b620:: with SMTP id f32mr37474680qve.228.1556431744301;
        Sat, 27 Apr 2019 23:09:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxu09tyODTQseg5t2zWPFztPYzC0m2fmVfUTVudU98JIqirtKT6b7y8Z64AxtcQ+UsXI89N
X-Received: by 2002:a0c:b620:: with SMTP id f32mr37474668qve.228.1556431743834;
        Sat, 27 Apr 2019 23:09:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556431743; cv=none;
        d=google.com; s=arc-20160816;
        b=CL2d6idSYQUYZKWcq+Z3+DNBbp7mchHlHp91ovekI7X8XsZWEhAFgJ3G/nK7S/c28x
         /9gJKS+VblVMFYHA6z+ZbGA8bAMWCneM42exLGJ/1hYctkBmGIWpJR4Va1SrVuzbgvkx
         R/VKKvqsN3xTq1HZ5aZLUW+K1NANOFLvbPiCQwLASjRT2jpQAjlmw725CPAKPSpbc48M
         lWT9njPL0ZOQOm3W2jJbdrk0g/vKJTqsl4PL+Fre7oTVigXuos5GKFYaHrDcZksbnvuW
         3NX/zeY7QWLzC8zxzYpk45xdKCWmiO7yiK0XNBtikMJFvxarpsSYIqdEuLGUZzIVqwQW
         KROw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=6wTH00IEcec2nG40s34dkAdJONtpHNStLOW3P3TBn8g=;
        b=MZo5junq6hBBBXGAyI2my7bvCMjerPOvOGPEHbhFPT4SpiCQkdj/7hYLKbdBauTliO
         YV5Vtq5lxct4sxDRK3c/uaM51Ed8u6Lz8K9ZU0LBCUaWyRQV0AVkW+njmWa3y6TOQLT8
         8+dJGnOwiYuEUu2hfJv7l4Dgj91WFKdwv7zE9OFbXUG+ZzcfCR0L+ilnpEn0D/ToDeX7
         xaE3i0G7L50tLuVGk50HV7qfiDO5YbQeaVezS/8EOGcN/tZKjVbIO2Al94rYt0Fg82DB
         5YimJlQhErL5VXYj15WbkXsBm3e6KiSHQ+xz5RaWECo68EG0BzkGogX2RxO3b/meaUoz
         CUWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gPOXauLn;
       spf=neutral (google.com: 66.111.4.29 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id m1si5728138qte.72.2019.04.27.23.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Apr 2019 23:09:03 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.29 is neither permitted nor denied by domain of penberg@iki.fi) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gPOXauLn;
       spf=neutral (google.com: 66.111.4.29 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 753A621FF3;
	Sun, 28 Apr 2019 02:09:03 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute4.internal (MEProxy); Sun, 28 Apr 2019 02:09:03 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm2; bh=6wTH00IEcec2nG40s34dkAdJONtpHNStLOW3P3TBn
	8g=; b=gPOXauLn3oavCa/+fi1mRLO3lBkOSJOxjAIjBVPq1SXu4Ma/pqCufZ0Yh
	lkD6VrSfaL+8phzGc/KpgoZ2c4fmukeJT3f2gE2hoAgraB69ky3vF3z00dsTgRsv
	EYqNp2nYv3yorE1n4FXWr7x4CX9lYIzG+kHpRa8E2WHYgq4cJj+SkJTGsoYxemVp
	ZMLjSuAaHhHLjJ0+DaHgQdQwEbnNJILvSUsnqPoHiHAYdX6RYy7NOe8EewPF+5e+
	025PXeYmwnUlx+84e7Q6RrNL+OBYA2qg2S39uMMBlvaO9CWpmRUIzigH6oH2xuqO
	UUcHwtqMMKZlYzVQlDV4UVw8uYLkg==
X-ME-Sender: <xms:fkPFXIx7NW-XzKazSd1QLI64oaA1yjeaxy9BlGm0WBA4e_7C8Fa4GQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrheelgddutdehucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhepuffvfhfhkffffgggjggtgfesthejredttdefjeenucfhrhhomheprfgvkhhk
    rgcugfhnsggvrhhguceophgvnhgsvghrghesihhkihdrfhhiqeenucfkphepkeelrddvje
    drfeefrddujeefnecurfgrrhgrmhepmhgrihhlfhhrohhmpehpvghnsggvrhhgsehikhhi
    rdhfihenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:fkPFXCQCaYwTgbW5nvDmuzfzyW6zd0XMhFeVbsdEwdZYZX0yQ1HqTg>
    <xmx:fkPFXH83G4alTfK5pCpAxFrD6JAv9fQsalCluIoc2NPE7ZsZtK-1ew>
    <xmx:fkPFXBoEYQACrpvjPcmdhNirX7B10AaxCymvGBVyRUaoAmuLeTai0Q>
    <xmx:f0PFXL71nyLUzjHpQdx5tv-cvxZYOnUeac5Sp7Qpi8K8pFr2Z0ZJXQ>
Received: from Pekka-MacBook.local (89-27-33-173.bb.dnainternet.fi [89.27.33.173])
	by mail.messagingengine.com (Postfix) with ESMTPA id B477C103DC;
	Sun, 28 Apr 2019 02:08:59 -0400 (EDT)
Subject: Re: [PATCH] mm: Fix kobject memleak in SLUB
To: "Tobin C. Harding" <tobin@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190427234000.32749-1-tobin@kernel.org>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <82b2272a-1d42-81e4-f033-8483d47bde22@iki.fi>
Date: Sun, 28 Apr 2019 09:08:56 +0300
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190427234000.32749-1-tobin@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 28/04/2019 2.40, Tobin C. Harding wrote:
> Currently error return from kobject_init_and_add() is not followed by a
> call to kobject_put().  This means there is a memory leak.
> 
> Add call to kobject_put() in error path of kobject_init_and_add().
> 
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

