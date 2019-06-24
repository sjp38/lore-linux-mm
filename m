Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F4185C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:47:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C609020674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:47:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C609020674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 603EC8E0006; Mon, 24 Jun 2019 07:47:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B44A8E0002; Mon, 24 Jun 2019 07:47:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CABD8E0006; Mon, 24 Jun 2019 07:47:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3CDB8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:47:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so20122588eda.9
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:47:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=M0c2K59XA0q5nOFsspYUeITIZrw4s1iMj+MpCQ3skKo=;
        b=H4H/WR/S8kDA6SbcCdgpEJq7QEn9CcjhocvTn2teBBtlOE1e1KnSzjYDeD7Di2tkBc
         6WderupGUpPem9KkKRxP0Urzvei8g4rgOCYJXFFymKTVU3nP8moofl0aiH6jBne7DMX0
         qgGuamwqSUz1DmKr4CSR73HMm/e6gPpblUoBqsnSd3banuHZ3RDrwwHgSfY3MVt9fjg0
         hTYvlaLI0Cua/XKJq8pM4R6RxnfNfiWJBM2KC5zOuH+yN1ZnczV8EQjZY1G6v7PsDpIG
         IChe50M8k2fsD9iM3fimhH+hrt4hyOai76keONhxuPyL4GTTyBzfzMWuwHPpSweEXVKJ
         GlIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAUBBdWFr15AmF8prunP6VMTpqFcd7Ye8HYbJ5veEaLR5eVnI5wG
	3PO/row3HaZvNJjUbThwy+bJOlnzoiHnrBFhp/GDNGOhYMZWLj/aL8nP6mCSee9DSFcfITFD3rO
	RR3Qg8LoAq0a5TzdgPo8x1aR4bgbbt40II1evEiitshAxAGRANO3Dwwq6A02FZ+1huQ==
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr2382110ejh.218.1561376832554;
        Mon, 24 Jun 2019 04:47:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzJrr8Op12L5ruQ5ZExPghYtiIsiU3EQAbLu4wdtABNbtz0Bx2/sypmlyLBISQLzQfo6be
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr2382071ejh.218.1561376831804;
        Mon, 24 Jun 2019 04:47:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561376831; cv=none;
        d=google.com; s=arc-20160816;
        b=fgF6O5ZH84WWi/zwiStfr5whLFyTebW+DjXuNrpG9rEfVtN4syQyFtUJObjI5h57ke
         wheL0wT5aBANjLbTK621p2lF0ixAVvFaZBQrnR2+/fEF5UugDoZ10UvBpfNcF6+YPt6M
         mk6S5QvB50eRKA6g17xFhutENE3K0q7t7jFqEHFfHYFzpZD/O81eCmd7u343U5OmK0mh
         AkTqKvqyNYs0UL2popSbzdrOhj8bDNzxQjpjJnmd6aFi9DMAW95t9qsOrB9R+wvY9PwY
         xsVZNqwOi++K3a4mnZNnizHpdWD5+NKozm9i6Crt+gc8EF4JMlKlY3sjU59kOUiwk94m
         2+mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=M0c2K59XA0q5nOFsspYUeITIZrw4s1iMj+MpCQ3skKo=;
        b=hBg8adbNulv4BHEO9p6JejpbYQTZM2JbGtq7qy/xrGuW4+731HcKMLm7E9AFTVk/GC
         cM5DFZrdZAKOwC2ovRwG42m8tLWhxth/2yAtUSQtRKvgzCbVPSIyqKQfZJNIJHM1sRQi
         OAj7XCzw2gPIQoqEimGt8qkB3nHFLtyD8X/cr7DZZ2QYggS+WgBOBjGdEybUzwgFsl2D
         35ueGkTyPQApQTTcpVJ7VGzdrjTNB16cRkftNsxBmmavi3ifAMN/r0iVCVQesJNf3x4r
         /3p36FPb05Tsa4bkg3yIappZwN0Sv8wLePwANuie4HLhRqU6lNiz1yi/zIVYUMLXe34Z
         yauA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 32si8065256edr.287.2019.06.24.04.47.11
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 04:47:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EDE242B;
	Mon, 24 Jun 2019 04:47:10 -0700 (PDT)
Received: from [10.1.32.158] (unknown [10.1.32.158])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7606B3F718;
	Mon, 24 Jun 2019 04:47:09 -0700 (PDT)
Subject: Re: RISC-V nommu support v2
To: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
 Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190624054311.30256-1-hch@lst.de>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <28e3d823-7b78-fa2b-5ca7-79f0c62f9ecb@arm.com>
Date: Mon, 24 Jun 2019 12:47:07 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 6/24/19 6:42 AM, Christoph Hellwig wrote:
> Hi all,
> 
> below is a series to support nommu mode on RISC-V.  For now this series
> just works under qemu with the qemu-virt platform, but Damien has also
> been able to get kernel based on this tree with additional driver hacks
> to work on the Kendryte KD210, but that will take a while to cleanup
> an upstream.
> 
> To be useful this series also require the RISC-V binfmt_flat support,
> which I've sent out separately.
> 
> A branch that includes this series and the binfmt_flat support is
> available here:
> 
>     git://git.infradead.org/users/hch/riscv.git riscv-nommu.2
> 
> Gitweb:
> 
>     http://git.infradead.org/users/hch/riscv.git/shortlog/refs/heads/riscv-nommu.2
> 
> I've also pushed out a builtroot branch that can build a RISC-V nommu
> root filesystem here:
> 
>    git://git.infradead.org/users/hch/buildroot.git riscv-nommu.2
> 
> Gitweb:
> 
>    http://git.infradead.org/users/hch/buildroot.git/shortlog/refs/heads/riscv-nommu.2
> 
> Changes since v1:
>  - fixes so that a kernel with this series still work on builds with an
>    IOMMU
>  - small clint cleanups
>  - the binfmt_flat base and buildroot now don't put arguments on the stack
> 
> 

Since you are using binfmt_flat which is kind of 32-bit only I was expecting to see
CONFIG_COMPAT (or something similar to that, like ILP32) enabled, yet I could not
find it.

I do not know much about RISC-V architecture, so it is why I'm wondering how you deal
with that?

Cheers
Vladimir

