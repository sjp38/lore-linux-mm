Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FB04C31E45
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 01:27:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6656A20866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 01:27:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="agp8Ljxg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6656A20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D98626B000E; Tue, 11 Jun 2019 21:27:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D219F6B0266; Tue, 11 Jun 2019 21:27:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC4136B026B; Tue, 11 Jun 2019 21:27:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CCC66B000E
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 21:27:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g65so8814885plb.9
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 18:27:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=CtAUnKccNVM3Ar1NimuBm5cYjQQHpUUV35G3NGl7I18=;
        b=Lqm3JRPO8XmBKKmdoR9kemUGy8t4BCDFjZGBr8SeD0V7omLSejA7JkuUGnLTz3zcxs
         Z2YhHXhcpBAF2hdLHKkYCAU4KncnXbGzdG1iHMmjRBHESJdYBnAHAEtIOpRx0dAQh4Vn
         JMl4mxSCVpz8tnWeG/F42lC1PrBYaXiH840js14m/uEUOuff3u+uev0D2CgeKt4hFllV
         YxlGn/zJgKovBbf1TbxYM1q280rDV6+/3Zx8kOb1V6ZEtAHC1JWVsPXle7RjBNDWGvfb
         rYFUXQ4AfxIt4gnGzYwmQyOBOgw4uNvQa6Y59+69W5Cz4VX/CDuXrAY/oiFR3nQ6F51d
         sSKQ==
X-Gm-Message-State: APjAAAURxccOIsDFJzJgxNWcH58i6G1YPt7iTkHaIMp7311L1Ou0yYul
	KCGtXtnA2gt2A6xD1240iaeETeI2W5sbBatyV5ar+vnaC3n38lrFFh0Aoaka6UkbVaJP2fPJT0v
	W7MycAo6KXnx+/70sEfyvh4advPxvvKXOfS0I97Je0gLwOppM5zC3x13gX2iy7T33Ng==
X-Received: by 2002:a63:4001:: with SMTP id n1mr21744484pga.382.1560302832909;
        Tue, 11 Jun 2019 18:27:12 -0700 (PDT)
X-Received: by 2002:a63:4001:: with SMTP id n1mr21744444pga.382.1560302832165;
        Tue, 11 Jun 2019 18:27:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560302832; cv=none;
        d=google.com; s=arc-20160816;
        b=a/MjVBq90GbYjuK4d77o/DWj9wtUeyoVGTciIqz1I/i7f2WpWfoo2dh88f0K/YIyaf
         14iCm8XunuZ4pj7kHw7O+fj27cuZ92rMyOwOtHbUYKUnWDjd3gsbkFhvd0z1B7KvHc3C
         03HSQGBPFWhM5yLJYwZz2aKepqN5WYLPGIklI+pxD7bm9Nq5tV79JkZtJRpe7ZtrxFTq
         JBA7t3PsWXABxY/V52rEfLk8MQENxxsr+1zjlMyVi3kvb0CfxoHX6IuKGmLvO7zZ+EtI
         niwoH3fWdt3Wn9fZslQzv9xM8hTT07qkzOU9EVi6FvwQIeq1h6H7FDoByVJsTDp0SoaZ
         m0DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=CtAUnKccNVM3Ar1NimuBm5cYjQQHpUUV35G3NGl7I18=;
        b=JtqYG54534VVc9puG4fetdRBzi2CL9T/DWEDQ/qJYh/8Gn+mCpHD2vQiFhQUAKVKEt
         uJP4S8FZUjYvQGVMZFjm/11CFvNQNF2VqrQTbrq99uUXflv5nQcUBRHamH9SZs1oeToh
         u0UwB5WDrgS3ovXXSpfpyn8iA1bV4QicHhJyqCx4XhhKrlXANI3cE7rX+HXqM22lMSAd
         ZkInjhWfOaJNqwa+wCkmIeaidGk7Hf4Cq9F0xPHsgY7mEP3WLTBwPYJhe6C0SgYYeAFD
         FWwqA8ZNuWsr4DxD8lchebDPQdnYNw+nvhqStQQJD+xPoUMCcKNW8uL6F3NgackdSXXa
         is+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=agp8Ljxg;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z1sor4826208pjn.1.2019.06.11.18.27.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 18:27:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=agp8Ljxg;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=CtAUnKccNVM3Ar1NimuBm5cYjQQHpUUV35G3NGl7I18=;
        b=agp8LjxgsiKUNBRzMQ6B1lsikXTP9MXAxScOYcZnsKclD0N+jlNVoUl/hzW4poyT5e
         3L5Kpn7BSqpfe4Vqr0OMLbW+npbpmydrSh4Nk6mj5SGyx5Jj6jf653H8VmcdoFa5nFlP
         PVXiNmiBrwZEiKboElbWiL4LdjFKAAbWcoG28ZIwtcy8dPhR9hlh49PJ6xikrmMZLHzP
         20qVkn6ttaCMzY1I08lsTIN5eoleBIFYn7aRuLf/OzGJBwoDwiiv7JFIo5WL8ooodEKt
         b/SI9mnoX3vTwRgRrKm2an9+aTc8TPah2tNonQDJrq5z+DrzQV1yJmuEkhrXeIPbcuOQ
         mhuw==
X-Google-Smtp-Source: APXvYqyJ4j/UPWrjvOrQasPCqbyNI8I79UTnDUErLKqAMrK1NLwjt0JJmzYLlyxhcupMkfrOP1908w==
X-Received: by 2002:a17:90a:cb87:: with SMTP id a7mr10403544pju.130.1560302831475;
        Tue, 11 Jun 2019 18:27:11 -0700 (PDT)
Received: from [10.2.189.129] ([66.170.99.2])
        by smtp.gmail.com with ESMTPSA id c10sm3547108pjq.14.2019.06.11.18.27.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 18:27:10 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH 16/16] mm: pass get_user_pages_fast iterator arguments in
 a structure
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <1560300464.nijubslu3h.astroid@bobo.none>
Date: Tue, 11 Jun 2019 18:27:09 -0700
Cc: Rich Felker <dalias@libc.org>,
 "David S. Miller" <davem@davemloft.net>,
 James Hogan <jhogan@kernel.org>,
 Paul Burton <paul.burton@mips.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 Andrey Konovalov <andreyknvl@google.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Khalid Aziz <khalid.aziz@oracle.com>,
 LKML <linux-kernel@vger.kernel.org>,
 linux-mips@vger.kernel.org,
 Linux-MM <linux-mm@kvack.org>,
 linuxppc-dev@lists.ozlabs.org,
 linux-sh@vger.kernel.org,
 Michael Ellerman <mpe@ellerman.id.au>,
 Paul Mackerras <paulus@samba.org>,
 sparclinux@vger.kernel.org,
 the arch/x86 maintainers <x86@kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <0441EC80-B09F-4722-B186-E42EB6A83386@gmail.com>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-17-hch@lst.de> <1560300464.nijubslu3h.astroid@bobo.none>
To: Nicholas Piggin <npiggin@gmail.com>,
 Christoph Hellwig <hch@lst.de>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Jun 11, 2019, at 5:52 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
> 
> Christoph Hellwig's on June 12, 2019 12:41 am:
>> Instead of passing a set of always repeated arguments down the
>> get_user_pages_fast iterators, create a struct gup_args to hold them and
>> pass that by reference.  This leads to an over 100 byte .text size
>> reduction for x86-64.
> 
> What does this do for performance? I've found this pattern can be
> bad for store aliasing detection.

Note that sometimes such an optimization can also have adverse effect due to
stack protector code that gcc emits when you use such structs.

Matthew Wilcox encountered such a case:
https://patchwork.kernel.org/patch/10702741/

