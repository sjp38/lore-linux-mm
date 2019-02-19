Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0DB3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 13:49:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D4472085A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 13:49:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D4472085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.ee
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC4098E0003; Tue, 19 Feb 2019 08:49:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D729D8E0002; Tue, 19 Feb 2019 08:49:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAF818E0003; Tue, 19 Feb 2019 08:49:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5B78E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 08:49:30 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id w16-v6so4124427ljw.6
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:49:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DImCeKeedU+uDgIYnppVAL5DW4iGsLLjoRcsZgDekJE=;
        b=bAmJ15QtJ04ylqK2QRBLnSau5kO6ukFwkbj+/fPjQWrhjLUfpEZ+YA/cUYyIiDC12C
         H8Ag1gYeOpp8fBGWDhp7y02uzO2F26xLML6i9l0VjBrU8x+1whh1fnm8dYURZVqraKBi
         DJQkgApxw6v9GNZO1e7RKwOkZvhsB0670LHRI8sEyGJaupaMzBZicLEldAJ9vsNMsp7E
         NUWmdcu+kgoKU3pX81EvdfffFHn4ojF3HMnVKAgpSHIaxjdWKjSFV94VBs3Wj9xXc3wg
         sQ+H8/Da3yCHdFE1OI95DilfTO42hWs+D3/YwxMyEZ5hp0y0b+SUmNxKrvPYU3xLFDjM
         gm2w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
X-Gm-Message-State: AHQUAuYLoYOm7HMz3cnVDW6UUv5BYcnlrqwsuTljwH3Mia4G2tHG2kVo
	nBqP2A/uDq5pXrwbheNS7NItPg2vl0SomVkJmuXwlBrs0oB5tzo/d9JHd4mXYYjh7HUdXGTEyQn
	qgGoee06fV+lNXYIEFUD174fICSIBpQ+r1iiF4q9vzxqVYWSNP7Z6ioHgfRmKOo8=
X-Received: by 2002:ac2:5224:: with SMTP id i4mr15475486lfl.145.1550584169783;
        Tue, 19 Feb 2019 05:49:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ8kzJc6tiCxI2+/HBkdHzh22UrfwiDetFO+oB7BoApiqSXcVtWFUTsPugaypO9KEF0Uj0O
X-Received: by 2002:ac2:5224:: with SMTP id i4mr15475439lfl.145.1550584168934;
        Tue, 19 Feb 2019 05:49:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550584168; cv=none;
        d=google.com; s=arc-20160816;
        b=PmXNRo7EZLW8sUfYaexJaq9LLyVzuvkZ6XLyWkQqy+L2LC14dWeQHlMD0MH1YOFb2J
         gLN0IzgPe7d+s0vjoStJ5rx5lh0chZa5xWK2RsJCrPfun9kBhnR3xyNpzA9Wv7PGSlDq
         3eFM9wq1FunOoxEf4xSC5Jno3sElyfM+SWKx0C32EgiHS75N8izzDbWC4YaV6EocR+Cy
         MFn9sAYqQBpA9oU9qoAIShEg0FJ1BxypotOVbAnZBPoky3/ViO+mkRTWhZGZJF0UAuHM
         MCYXFNxcIbo7a6oKlgIsJ8A9m6F81tLWCshnf7fBnX5fsWRJu9alShSIRl4dgCDhotZz
         bgQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DImCeKeedU+uDgIYnppVAL5DW4iGsLLjoRcsZgDekJE=;
        b=eZDvdeAC2fo7OtB/CAQwBt7Y3qrKxhAZ2yvlW6XYmhWQAArIgG+c1xR3tPWfZC37IB
         1UG1JZqH4LJ7z2aztiF0vnNaYe+BCDrfS07iJQrEgJGadzXMenfXC2VZ6Hm177j4j5UQ
         5qnQxm34kM7ZGti47KZs8bOMZyUWKS//FNLMeT9i/RnpAhb6lZmXzU5E+zIEUns231/c
         068W7HdqJEvR6QpeU74Y5d8uJYWVVx3Z1hK9uva0R240bIZ95AlIUjvUVwIkr2dzyz3f
         b1n9Wgn0yM9yOUspO/jfr3mHofyxeDaTzPFrOi8nyZATYZvvwW6507KK4j+0rF7ZeRs2
         7CGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id p69si8101762ljb.75.2019.02.19.05.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 05:49:28 -0800 (PST)
Received-SPF: neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) client-ip=193.40.6.72;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Subject: Re: ext4 corruption on alpha with 4.20.0-09062-gd8372ba8ce28
To: Jan Kara <jack@suse.cz>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, linux-alpha@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, linux-block@vger.kernel.org,
 linux-mm@kvack.org
References: <fb63a4d0-d124-21c8-7395-90b34b57c85a@linux.ee>
 <1c26eab4-3277-9066-5dce-6734ca9abb96@linux.ee>
 <076b8b72-fab0-ea98-f32f-f48949585f9d@linux.ee>
 <20190216174536.GC23000@mit.edu>
 <e175b885-082a-97c1-a0be-999040a06443@linux.ee>
 <20190218120209.GC20919@quack2.suse.cz>
 <4e015688-8633-d1a0-308b-ba2a78600544@linux.ee>
 <20190219132026.GA28293@quack2.suse.cz>
From: Meelis Roos <mroos@linux.ee>
Message-ID: <6cd92b22-742d-f6d5-5b6a-180884fbbf20@linux.ee>
Date: Tue, 19 Feb 2019 15:49:27 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190219132026.GA28293@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Thanks for information. Yeah, that makes somewhat more sense. Can you ever
> see the failure if you disable CONFIG_TRANSPARENT_HUGEPAGE?
HAVE_ARCH_TRANSPARENT_HUGEPAGE [=n]

Seems there is no THP on alpha.

> Because your
> findings still seem to indicate that there' some problem with page
> migration and Alpha (added MM list to CC).

But my kernel config had memory compaction (that turned on page migration) and
bounce buffers. I do not remember why I found them necessary but I will try
without them.

-- 
Meelis Roos <mroos@linux.ee>

