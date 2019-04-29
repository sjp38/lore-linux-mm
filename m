Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4750C004C9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 23:23:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8706220673
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 23:23:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="ab1DViiw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8706220673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2DF06B0003; Mon, 29 Apr 2019 19:23:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDD316B0005; Mon, 29 Apr 2019 19:23:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1DB26B0007; Mon, 29 Apr 2019 19:23:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A81C6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 19:23:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j1so8166323pff.1
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 16:23:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:subject:in-reply-to:cc:from
         :to:message-id:mime-version:content-transfer-encoding;
        bh=YNd5XIwM5sGIOIL8C1Ttqmlb7fzBV2yqKuzpj9z/xNY=;
        b=PbH+F5LwvbwG59WSPtzQ2T6lWcW14EGT2NxanO1FIgbeHKGFY0Dajg5w1EJVKEHQV4
         gyQgCm3lrngN1JCltprVmmTHgTqgkWsoJE6mlCNvhAL1EJOj/yfqGVqIWpuwnnCPQYT/
         M5nXJkCd/FM2ZO8KZKHDZ2lIBZUk67w7KKYY+ivhCYZ/LLncix3wsN/kHallGIbQXrJl
         /hlx0yMDjuK+gNys6+HPJWFG9AExzeu+Ba5CXQCRB/SOTFrxiWiNYR007AYRkhlFRaGA
         6lJFUWAQoFnbAuQHb8CUn7InycWMASxVb56cmKid3pfntEyYgHV0ErfuP5e3jA3JI1eZ
         yPkw==
X-Gm-Message-State: APjAAAWw9dNzw1zNhMUsUWSza8AuEtEM8ers2nn/Y5HFSp0cXH//Fm4K
	928EVvi9TtFK18VddRCIwSBgUSAU7H/iH3Cbc/0UzTAURVwBEYJKHhRLIAxaXIxMWfCNM26p2Qm
	vLKVzT9lc1gpyvKD/4EkplF7stz9nzvOn1C2nAVhlCnmG9H+UNF5fNXuO8Oj9XnqOOA==
X-Received: by 2002:a63:dd0f:: with SMTP id t15mr29975652pgg.414.1556580223179;
        Mon, 29 Apr 2019 16:23:43 -0700 (PDT)
X-Received: by 2002:a63:dd0f:: with SMTP id t15mr29975583pgg.414.1556580222376;
        Mon, 29 Apr 2019 16:23:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556580222; cv=none;
        d=google.com; s=arc-20160816;
        b=XxsJvbwmGY3SSESPxr+yoILS4D+5WYjAvLJmgf0gQ21EUeyFS7qlP+01RQr3DffgA5
         bxgJGu0Iwq1BL9l/t3eybv81Zm2RnL2BIqTlyAcsOk35UvCKE8j0FsR0OHNeSOLJ4jS4
         jlQ3egiL/ZN03GoKlayiHWEGkwGeuzY0i2/ufNXvH1P7UMsB+3Kmq4osZKMbBTjzOwwL
         e/0mqzyckcQ6/8mCTus8CCZ4xcYtVPi5uYv+neEbYqmyV/zTXXeaCFPqZ+rj3W5m+EWs
         8jWeFvyykJuZ+Ziwnoh2DGbAcrk8sRYtMGnHljVZ7aweZH0WdYLQiUxKWsZtGC8zC7rs
         3KZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:to:from:cc
         :in-reply-to:subject:date:dkim-signature;
        bh=YNd5XIwM5sGIOIL8C1Ttqmlb7fzBV2yqKuzpj9z/xNY=;
        b=sW44steDLZkKJxndLMEcq+Nc3xMB2i+t3W9ZzjCHtJr0iQXz/74aPunTHNkZHFbibF
         8RMQTcZastANiMlDEuRyyAegmM75VdGMufkWsCtUqNi2jZOcIveDGDfvE2M7wrKhEzlr
         4IVE9nCqw+gAKt+3RMkhARsvI5AlCgM73ogTikOv2hopD8pp4jzY1NTSL6+3YWcnkQd3
         TAcYONj8BqJqkxpPwOWpeJLKYdxwNpw2FPZ4qqVBK3eurUrzUcyzTN0HeZ/kfRYTCMH0
         ySYIId3lfn/yGRg15QaYgufHnY5Y6Y/PqkP9Wy3zEDk9Irclm1fOwExniuz5RKKpj/FG
         47pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=ab1DViiw;
       spf=pass (google.com: domain of palmer@sifive.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=palmer@sifive.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 11sor23347026pft.38.2019.04.29.16.23.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 16:23:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of palmer@sifive.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=ab1DViiw;
       spf=pass (google.com: domain of palmer@sifive.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=palmer@sifive.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:subject:in-reply-to:cc:from:to:message-id:mime-version
         :content-transfer-encoding;
        bh=YNd5XIwM5sGIOIL8C1Ttqmlb7fzBV2yqKuzpj9z/xNY=;
        b=ab1DViiwuT34vHIps7vB/KNE1BO5BonTPRVwKQE0PrPQTTpdiCtcaNK63Bidkc/mNK
         pyaohy4NXFao34rOEaPmshyXKcMsOvfpYDr9+DLdi9AHxnUXgHl+chSGx8/p4GKaHrK7
         keQDOgdPMFEZeYK/8kfOfWp3NcRVQTyRWHRKU992WZa4YAuO/3T5UZEYnsqRU00exL4J
         V2A6rGUs5Y1F9nbzKS6nlP6IwqVImW2LXwMaQoQOeGTUL/JaWwxKlq1BsEJ4yP/pn0vx
         Xume0+/+QcXdhcfvgLX18liPAwEIohhRMFRNPMiEOzBfEwiKo3uQP63nZQEsIiOI00oQ
         oC7w==
X-Google-Smtp-Source: APXvYqy0pkiYAo4kNCFYdQsYAUNSH2awhHznPjw5awZA0OodMxIfPtIaWKtzt1knemtdMwoGkGJxFQ==
X-Received: by 2002:a62:5885:: with SMTP id m127mr32599935pfb.33.1556580221466;
        Mon, 29 Apr 2019 16:23:41 -0700 (PDT)
Received: from localhost ([12.206.222.5])
        by smtp.gmail.com with ESMTPSA id l15sm22555931pgb.71.2019.04.29.16.23.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Apr 2019 16:23:40 -0700 (PDT)
Date: Mon, 29 Apr 2019 16:23:40 -0700 (PDT)
X-Google-Original-Date: Mon, 29 Apr 2019 16:23:33 PDT (-0700)
Subject:     Re: two small nommu cleanups
In-Reply-To: <20190429115526.GA30572@lst.de>
CC: linux-mm@kvack.org, linux-kernel@vger.kernel.org
From: Palmer Dabbelt <palmer@sifive.com>
To: Christoph Hellwig <hch@lst.de>
Message-ID: <mhng-3cb7e3ad-f586-46e0-8c29-48ab828607d2@palmer-si-x1e>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000012, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Apr 2019 04:55:26 PDT (-0700), Christoph Hellwig wrote:
> Any comments?  It would be nice to get this in for this merge window
> to make my life simpler with the RISC-V tree next merge window..
>
> On Tue, Apr 23, 2019 at 06:30:57PM +0200, Christoph Hellwig wrote:
>> Hi all,
>>
>> these two patches avoid writing some boilerplate code for the upcoming
>> RISC-V nommu support, and might also help to clean up existing nommu
>> support in other architectures down the road.
> ---end quoted text---

I don't actually see any patches, can you point me to something?

