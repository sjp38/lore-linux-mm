Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CE51C48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:08:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E657204EC
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:08:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E657204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E4D18E0005; Mon, 24 Jun 2019 09:08:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 995658E0002; Mon, 24 Jun 2019 09:08:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85D1F8E0005; Mon, 24 Jun 2019 09:08:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35E068E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:08:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s5so20381361eda.10
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:08:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1eYipjag048mHuiA7OAV4PsGwY6OaH3lXVSFrCq2e/g=;
        b=JmV7Zh1eDVaccSiBqTrwsL+pW1G/ZLYFWEYGg/W6lnooffw10EZvCgaQVhKZzNkqB/
         aoe69vL8Ksx4/C1mzSJ9M69WBd2ib9fZVj5X9A9BZx2MHtr4bedth2KD5PQSeRIPeIva
         D8VlghncFdRD0nrPGNO39xNAYS4o4kVx36fblI5Tixa/Ol4So8iq34QcQtvhMZROmtzr
         33bgdtWzGR8wx/X24ikURoLiS9Dh4pZjOZ6tK6zeSuEYMu/og0mzG+4OhPDfwAhtDa8w
         DLnioVJeXI380JKmgMUQOM4AvvCcaol+rDeIlgIprGmvIvkH1FDqIJ3cD7+8jk5TU11p
         p+Gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAVj6J88kJwlle1AkH4e1YzT5ZE0Mwt/f/5VVhjZGj17cW9Nk5/L
	SrGgF9z0sosuzAX0OC6ZyBKEPki+6zf3yb41MuBbZa51iWo+EOBKcaLK2el39rooZfTQ5KRwU1p
	+S//1D0q4GP0O/ahVovpM5sc+lMiBapZ6aGSoWoXJS8ArxPYd8k8/2mNRd9BLKe7UkQ==
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr82890834edd.61.1561381734780;
        Mon, 24 Jun 2019 06:08:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3mudxcwpTAF/H9qigwNf7cYgK99vMCZCllkkGi8WqyO/CIEhrr6PurNKLmUKsft4WiZnM
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr82890761edd.61.1561381734150;
        Mon, 24 Jun 2019 06:08:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561381734; cv=none;
        d=google.com; s=arc-20160816;
        b=k5l/CpAchIhH3Gg1mLettrF4tsp/8k6C/il4IRbmE8kmOd9Dt/VZykkcE9hUMdkrZc
         LolC/d/bs1SYvptl/ynxe4wzHr2dVP0WDXTJ8eHYcdsE5Rizw1K7VZwlornQVlewG+A0
         7ttmJt2LYYO7Ds5puHl9Gvk0IO5N/j0fExe23hOeNdbquRKb2+0MDPpPhKRf140jon3L
         5BSsD/e7FwNOW3/zDs0V1X7r880lntqhXw9ujEV20rBedgu26XlpwWR15OilZuPyvLqe
         idkRz/bGOXm5BrdopyTzRYc+/ZrmgSMWKu6y7agW/MBM8h7UGudDwbAfwfxJiPnCrozw
         l19A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1eYipjag048mHuiA7OAV4PsGwY6OaH3lXVSFrCq2e/g=;
        b=DgPT997pGKwgfxjHtmWPi/5T6heiER9qlKgDiNZlwY10CXyBJoqRpQ8PSEtmlshBG/
         aEtHWLlHCbanKiVhnwu0gtTNtByuPbLVW64cDxgTFoR5DZlUEP9iYNbm9Zx/+Nzobm+V
         7HGCZWBiGPStZIEYxn4+TvD7000VczNXZCyUNJuxdtsI+4r34bULrhzSKRt9I9jMCTny
         WscU6emLzo/qjMDKIo0Ow2oA7JSuQZ8HJN9eddIoJVNoRvsKRN2UIt1Tw1iZp36zI0kY
         rcj2PJ62g1F+xdGru0b3vQAZ9ua1ZVDMy138TQM42RS6pxORnb+u5wQu3tCRuRckL/Zj
         4e3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id j42si9202556eda.80.2019.06.24.06.08.53
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 06:08:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4D4FD344;
	Mon, 24 Jun 2019 06:08:53 -0700 (PDT)
Received: from [10.1.32.158] (unknown [10.1.32.158])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BB6A33F71E;
	Mon, 24 Jun 2019 06:08:51 -0700 (PDT)
Subject: Re: RISC-V nommu support v2
To: Christoph Hellwig <hch@lst.de>
Cc: Palmer Dabbelt <palmer@sifive.com>,
 Paul Walmsley <paul.walmsley@sifive.com>,
 Damien Le Moal <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190624054311.30256-1-hch@lst.de>
 <28e3d823-7b78-fa2b-5ca7-79f0c62f9ecb@arm.com> <20190624115428.GA9538@lst.de>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <d4fd824d-03ff-e8ab-b19f-9e5ef5c22449@arm.com>
Date: Mon, 24 Jun 2019 14:08:50 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190624115428.GA9538@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/24/19 12:54 PM, Christoph Hellwig wrote:
> On Mon, Jun 24, 2019 at 12:47:07PM +0100, Vladimir Murzin wrote:
>> Since you are using binfmt_flat which is kind of 32-bit only I was expecting to see
>> CONFIG_COMPAT (or something similar to that, like ILP32) enabled, yet I could not
>> find it.
> 
> There is no such thing in RISC-V.  I don't know of any 64-bit RISC-V
> cpu that can actually run 32-bit RISC-V code, although in theory that
> is possible.  There also is nothing like the x86 x32 or mips n32 mode
> available either for now.
> 
> But it turns out that with a few fixes to binfmt_flat it can run 64-bit
> binaries just fine.  I sent that series out a while ago, and IIRC you
> actually commented on it.
> 

True, yet my observation was that elf2flt utility assumes that address
space cannot exceed 32-bit (for header and absolute relocations). So,
from my limited point of view straightforward way to guarantee that would
be to build incoming elf in 32-bit mode (it is why I mentioned COMPAT/ILP32).

Also one of your patches expressed somewhat related idea

"binfmt_flat isn't the right binary format for huge executables to
start with"

Since you said there is no support for compat/ilp32, probably I'm missing some
toolchain magic?

Cheers
Vladimir

