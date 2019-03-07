Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17916C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 00:22:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5BC620842
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 00:22:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rdJBXQWf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5BC620842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 629CE8E0003; Wed,  6 Mar 2019 19:22:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D94B8E0002; Wed,  6 Mar 2019 19:22:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A24F8E0003; Wed,  6 Mar 2019 19:22:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23F888E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 19:22:41 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id l10so11097489iob.22
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 16:22:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from:cc
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iIWkAuLqjZp48a6KUYh7dQ4ey2EITMMpWIX4xWhIWFY=;
        b=edB+oFPMugjN5VgMT751t/pwIwktBbuZHxxQ6PODvCa0CuzGBLLvfBDH1J4gi1XxPp
         G7mSk4QotPnmwUt0oh8c117Ccymx7fXWVr6vebF/QcgJBxaCgy3k7wl4aFoehsxfs2YX
         IqyMAKaQW+feO97Klosvysk2WXVsDDNnuBvyPy2/YSYF/6wG6rlYadN5DvuVk/X+PcBX
         NPpYf/qCkgfZk+SJMgw2TAieZq733XdE0eGZaP9U4EgL96cBo0VC2VghqQVIFU5lbfjz
         jC0BFUfRH4q1rOGDDeBB7dwUxtS2MuKiLxuRN7oCWMBbg9C8YIne62cw6gVIyydiPFyy
         J+Rg==
X-Gm-Message-State: APjAAAUF6yfNjFNcJQotHj18wb0kiC+8RlY4961CgMRKqjmTzQPOj6yF
	iNXJASDu/RyOO+X3UoyMueqzOJtHbijM7VVK+C2CPTYXwSyuJudwAvFm3bnWDwka6L15crykL1y
	+3m0owUqAdIzUeduurpdTqF+rpsnJ6yZjT72ZEult/cb0w64fjww42ZE5slZlvMAiGA==
X-Received: by 2002:a05:660c:243:: with SMTP id t3mr3720317itk.152.1551918160866;
        Wed, 06 Mar 2019 16:22:40 -0800 (PST)
X-Google-Smtp-Source: APXvYqylwtgQ+Q+GhNyV+mNT1k7LFcE9BC2smqqd/o8g8UVY66d5vxFH4z2MYomunyn/JfT424Zo
X-Received: by 2002:a05:660c:243:: with SMTP id t3mr3720287itk.152.1551918159877;
        Wed, 06 Mar 2019 16:22:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551918159; cv=none;
        d=google.com; s=arc-20160816;
        b=LqIozOLqvWkZFALW232kEV2cRBc7ZADqiEyZa6pk23unfnj5MfveahVUf8tuSoqHMz
         DJ72TAKj/3gkGszvp6yxxOr4yJ35tvE7xY8Jndx5FPJwNWyEpyLDlICk1YpJikCG4m6T
         CsoxGUYE6yAN3KwCBzyj0NJpopZC0YVh71hYdFk++ljdvGD+eUaP5qP88yEVQJJi2Kf4
         7Cz+l4SJ6dsuSBMNokUydsgr+YWt5ilhZialnz4XrpojmemzDxsh+5BJS+q0LKLWrxJg
         hHl3cBe5N+5/h6MnhjpeJh3E7jBsxTESr52mEq7mdU2S7cRP/3uv4rsbUmxCWfQ5SFm1
         LVGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:cc:from:references:to:subject
         :dkim-signature;
        bh=iIWkAuLqjZp48a6KUYh7dQ4ey2EITMMpWIX4xWhIWFY=;
        b=b/uocg6WUAazGETb9V33RzJhRZiGdCFMmOYP4OPEAO6c20QktKLvhb7wRo2VIoPM7l
         POuJT6CYI5Pn0ASPM/4d/tpvbRgVkdpnktVBaG+GvRXQm+34cw0OcpVWhPpZir/yVH6Q
         Bxvf0KY5cCd83SZsO1fn1mSQpOJjj1VV+3bKp6j7HfSmpUgwCd7YPZFIkDvdFyB3aXo2
         s6b9hyf2MuD+WBqj7BeFmwo7NWiQ1D1oN//fCi2w+GgtglFuipzkEsyOhZRiPcIfV6pe
         ElaJelpM2DmoTl9B4iKQXIfK0C8SMmtc/X4k3mygkhdd1uwuVBt9G6wzr2gxhOZk2rJP
         nKbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=rdJBXQWf;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e184si1823100itg.29.2019.03.06.16.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 16:22:39 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=rdJBXQWf;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:Cc:From:References:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=iIWkAuLqjZp48a6KUYh7dQ4ey2EITMMpWIX4xWhIWFY=; b=rdJBXQWf0FwtOdyV5cwEdsh882
	MFCt4Z+lANe8eTOzI2e2tYH6fX3CBY6MoPSes6wi6QhlEZulw1NtT++z02g8kGSUJ2a3CUtK3NTBi
	NG2y5DTWtxBXBWDmAdGnjwzIlCNr1UEPE9qyEflVnVT/oeTMiMr15AajpBNBXfq4Y2h4I/uE3VRDQ
	pVOyXn0TsjRQP9s8ZeZw7zLdVcSk658TsESqzXobq2HF1PaOfzmnrSv7RskOZN4Dj3m9a05ChGPnN
	hS86lPgWMLnRwAM2SJe4ZhLQLKznRzwo3gVXupRE/C3S28adBqc+nO+3As1XzYwtqkn7QrGSRsh2U
	ljjfOF+A==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h1gnw-0007Fb-GR; Thu, 07 Mar 2019 00:22:33 +0000
Subject: Re: mmotm 2019-03-05-16-36 uploaded (zstd)
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
References: <20190306003721.eX4wF%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Cc: Nick Terrell <terrelln@fb.com>, Chris Mason <clm@fb.com>
Message-ID: <a02fdae6-1f3c-6725-88e5-73316017f5ac@infradead.org>
Date: Wed, 6 Mar 2019 16:22:04 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190306003721.eX4wF%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/5/19 4:37 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-03-05-16-36 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
> You will need quilt to apply these patches to the latest Linus release (5.x
> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
> 
> The file broken-out.tar.gz contains two datestamp files: .DATE and
> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> followed by the base kernel version against which this patch series is to
> be applied.

on x86_64:

../lib/zstd/decompress.c: In function 'ZSTD_decompressStream':
../lib/zstd/decompress.c:416:2: warning: argument 1 null where non-null expected [-Wnonnull]
  memcpy(dst, src, srcSize);
  ^~~~~~~~~~~~~~~~~~~~~~~~~
In file included from ../arch/x86/include/asm/string.h:5:0,
                 from ../include/linux/string.h:20,
                 from ../lib/zstd/mem.h:24,
                 from ../lib/zstd/bitstream.h:54,
                 from ../lib/zstd/fse.h:228,
                 from ../lib/zstd/decompress.c:32:
../arch/x86/include/asm/string_64.h:14:14: note: in a call to function 'memcpy' declared here
 extern void *memcpy(void *to, const void *from, size_t len);
              ^~~~~~
../lib/zstd/decompress.c:426:2: warning: argument 1 null where non-null expected [-Wnonnull]
  memset(dst, *(const BYTE *)src, regenSize);
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In file included from ../arch/x86/include/asm/string.h:5:0,
                 from ../include/linux/string.h:20,
                 from ../lib/zstd/mem.h:24,
                 from ../lib/zstd/bitstream.h:54,
                 from ../lib/zstd/fse.h:228,
                 from ../lib/zstd/decompress.c:32:
../arch/x86/include/asm/string_64.h:18:7: note: in a call to function 'memset' declared here
 void *memset(void *s, int c, size_t n);
       ^~~~~~



-- 
~Randy

