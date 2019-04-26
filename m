Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1FA7C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:40:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6797B206BA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:40:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="LLcbJytR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6797B206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B54186B0006; Thu, 25 Apr 2019 22:40:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B011C6B0007; Thu, 25 Apr 2019 22:40:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A50E6B0008; Thu, 25 Apr 2019 22:40:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7006B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:40:00 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id ba11so991833plb.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:40:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VO3iBFMkWhmrJrV24wpgxspECFNCTyofN0BzMsoUTLQ=;
        b=IwUUDJoBF8u1B23aBZ7A0jLls8xDySf5xCNQV2/oLV0w5f7ASLhSzRBj4hVWznv++C
         38z3vkj9sByUT9aq74clUpbp1ina+mNDAIjuxpHWSRpe/stRcI6jbOf2Quf76KDhvE3R
         8Gf5Bc3D6LIRg2nm2kDkieSUc65ctDp2ALUIEC4Xgx43edScbYuo+yWSRAUuxnuaLUDs
         zIYxS+4zCp6unYs2Zn/H6yHV51hTicPPSGR7WkEQybAClImrHyVOw22jQKBROgh9TRrZ
         JgY9XHJYS9emHSv9jysb2TgdJldGkS23NPjikicFrQcxI1+lbrytEhY7aqvSO4l1q15Z
         ZbGw==
X-Gm-Message-State: APjAAAXH3VKj4rwbVCN7XcrB6htDANx1mlWlI1ja180KU1pIZAubt80F
	IdFB5Lhz7iV88HZaGwdtaPIAQRU1wS3fGzRy97MFoye48euMNXsoI8x/ab4Lg4XRb79jm3ACjW/
	dWbk8F6B97YlhnlVaqaC8B2K8cmAIPMME0vW4i9NMcSaCVaOf/hL6m0nkEojEHdLrtQ==
X-Received: by 2002:a62:4d44:: with SMTP id a65mr5399952pfb.150.1556246399850;
        Thu, 25 Apr 2019 19:39:59 -0700 (PDT)
X-Received: by 2002:a62:4d44:: with SMTP id a65mr5399874pfb.150.1556246398708;
        Thu, 25 Apr 2019 19:39:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556246398; cv=none;
        d=google.com; s=arc-20160816;
        b=BaEFuKPvPztvkEwy+ldi3nS8AAtRnY7181UpjCy9zemaBtZ8vjwss6iOQw3YOopZ0j
         gggHDP+1PkOeeeiEIFdpGcdG3ZGrQKm4UyBGDvyqoIUkU5mC0THGcyLNJ76vm8g8kwEC
         vY8bNJFihgFJVYYtc3P5APHbBaRahNttkt3U+f38qQSFpsKTFW9mjbgQQY3JUMRSORQW
         uUYPnZx0qc7d0l9xOKFx2Gdwg2Zx614iZcyhhuq/Vyy+ryoEzK4XMNQpM9dSUUxd9wR5
         e+qqzNup2hpywC1Yos+8atnn4Kl5+H6U48boMA2508lpCSyGGg0Hv4Omy90RPOTDPE8E
         hjzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=VO3iBFMkWhmrJrV24wpgxspECFNCTyofN0BzMsoUTLQ=;
        b=o729bUd64iCVSE4O6ho0tRG7zGFiUF6dYQMQVRR3zUl7OoQ5lSrbcFD1HzsRGGBBL2
         QAk95Ytbe1GHV1aKzIMS51oizzhIHbR4CF4y8AIlBGJE8wnN99oF960SaZkVyFi4Vyst
         ZK/B2jeQTOFxhwHk6GcslrdO0snKzqB4AVCRwhwB56XlcfQuIOdfFO/Xg1j4DSeP/GQs
         gU1TgPhziEpFNEVt8EJctdqRmhTEz35D4oYYJ4FFKWUjqIVuAILf1Zj6FTUmjXGoKFVP
         6Xmbfbe6HQXqlSwDUpVJIT9bB5b6QNb9wsI+UIlkvX+M05F+KKJA4EjcGrOXzM1Y019Z
         k0CA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=LLcbJytR;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 59sor22838926plb.24.2019.04.25.19.39.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 19:39:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=LLcbJytR;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:references:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=VO3iBFMkWhmrJrV24wpgxspECFNCTyofN0BzMsoUTLQ=;
        b=LLcbJytR27KzYvODS/mG8EoR/6HefQiMUIVwP3LP27thQ7cSxfvw637TF9QubMQB/G
         gNdKVY9Ohe6zolUH3G9KKkoCqddapgRAYzQUQma9W4SKsZi6dpC0/E3DugJW7YIrJrNL
         Ipb855ozjGSuuY96EsxTDP98p+pkiXoj+DaB8lS0+TBjKGeG5bLN5is9tbQ8LY4nLh2p
         11gTllvu4bVXmrltM7J0yT1NTMDxSwEhmU9g+l40ydLVx6RxbsS4HQtIdN7Cm8JKglRk
         iY1CbEgf0AUKw9F1v2LnFXdRFt0s+azuUJp9e1CffftnwJ/ypp16Na/T4pkjBN4y1ly7
         Arfg==
X-Google-Smtp-Source: APXvYqwVFhKqwvVZkXVmb6SFTLR1hz5lT4AQByaHEtQDU6UXaJfhlw3/073UFDsW8JGZTPHaB0iK3w==
X-Received: by 2002:a17:902:bb90:: with SMTP id m16mr5819205pls.340.1556246398081;
        Thu, 25 Apr 2019 19:39:58 -0700 (PDT)
Received: from [192.168.1.121] (66.29.188.166.static.utbb.net. [66.29.188.166])
        by smtp.gmail.com with ESMTPSA id b19sm30534749pgb.51.2019.04.25.19.39.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 19:39:57 -0700 (PDT)
Subject: Re: [LSF/MM TOPIC] Lightning round?
To: Theodore Ts'o <tytso@mit.edu>, lsf-pc@lists.linux-foundation.org,
 linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190425200012.GA6391@redhat.com>
 <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
 <20190425211906.GH4739@mit.edu>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <cf2c4c2b-678a-bda9-bcee-7dd28894e53d@kernel.dk>
Date: Thu, 25 Apr 2019 20:39:55 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190425211906.GH4739@mit.edu>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/25/19 3:19 PM, Theodore Ts'o wrote:
> On Thu, Apr 25, 2019 at 02:03:34PM -0600, Jens Axboe wrote:
>>
>> which also includes a link to the schedule. Here it is:
>>
>> https://docs.google.com/spreadsheets/d/1Z1pDL-XeUT1ZwMWrBL8T8q3vtSqZpLPgF3Bzu_jejfk
> 
> It looks like there are still quite a few open slots on Thursday?
> Could we perhaps schedule a session for lightning talks?

Yes good idea, I've added it. Like previous years, I imagine the
schedule will remain fluid, both as we go into the conference, but also
during. So we can always add and/or move things around.

> I've got at least one thing that I'm hoping to be able to plug as a
> lightning round topic.  Folks may remember that a year or two ago I
> had given an LSF/MM talk about changes to the block layer to support
> inline encryption engines[1] (where the data gets encrypted/decrypted
> between the DMA engine and the storage device, typically EMCC/UFS
> flash).
> 
> [1]  https://marc.info/?l=linux-fsdevel&m=148190956210784&w=2
> 
> Between the Android team really trying to get aligned with upstream,
> and multiple SOC vendors interested in providing inline encryption
> support in hardware, we (finally) have a few engineers who have been
> on implementing this design for the past few months.  If all goes
> well, hopefully RFC patches will be published on linux-block,
> linux-fsdevel, and linux-fscrypto by early next week.  Assuming this
> happens on schedule, it would be perfect for a lightning talk, with
> the goal of commending this patch series for feedback.

Agree

-- 
Jens Axboe

