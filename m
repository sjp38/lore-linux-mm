Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D02E5C10F06
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:26:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9925E2192D
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:26:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9925E2192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 134528E0003; Sun, 17 Feb 2019 03:26:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E2E88E0001; Sun, 17 Feb 2019 03:26:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3BFB8E0003; Sun, 17 Feb 2019 03:26:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C140E8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:26:34 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 75so11175762pfq.8
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 00:26:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=ftxkWchyFbaweklNC2tPHH4we0OIRk56ARBfnXFaUWA=;
        b=lwgvP2HyxridS0OUjOVrH1HlyMhANBEFIFEk7nfiy0vSOeTo5bAEqyBE/sojuTzQXH
         7TtsOcQXgc21IJJe5ybrdVbTqHREJqk6yMitr9ZJG7kHnQEV7F86LHH0Yl8pD7OKYAhY
         GdIPakVzgKQ8RYxqxIWVK22WVGE78bz5IWyUyyQ7SZy4j6CFjxis41V9TJVMLLrb6skE
         xzFWj0mywa/jud8QM1mv/YS2ilnrFtgcHO9z9sxDJMVxR9uvy+9mIpGTQtmBH/mc7PNH
         sKcSNCv1Ll/5W3ef4xXCl7nnA+kjSlg1/Ex0lksw6CgPaBI1C9IW/l2BjZa1CtLYTE+O
         5/Wg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuZ+rO65k8T53cDkyZRYyK3niQC/5d5L89WONETcmlr0BFUCLSdH
	6LeaQ08AI7PDziUYX8KvUrGFh3PkwpYF+3NuKm08d1Hb2GnOPh+O4voD26f/yszSwdEtJjmkBeG
	8SW1+P2CzcgrZWz4v0nnHKOp+UDst/EESIUuOlBqy4E+OHM2MZ2MMJTVtrxtkzkA=
X-Received: by 2002:a63:d507:: with SMTP id c7mr5901364pgg.105.1550391994449;
        Sun, 17 Feb 2019 00:26:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZvXR6Sz5lIdV1XWWRPdDgdM7YcH6vyW2KyH1ghbfF31EIN8Nzl4xlEAqcAhU1EWuAmrpcA
X-Received: by 2002:a63:d507:: with SMTP id c7mr5901345pgg.105.1550391993825;
        Sun, 17 Feb 2019 00:26:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550391993; cv=none;
        d=google.com; s=arc-20160816;
        b=Lmqi4Xe3XaDGYJbJUs3GwVcaIzjjhLh2zRWiM9ezjRPmPiJ1ioOmyrx3u3Fk8q5Vjs
         TqYzQ+Vx5JkyBnvw1zL6g+4naB/CazXrrQrG2y8p9jSoAmh9SRTgPni3SRmZ3h218+dw
         8pBqa2gAI32kOMIYIWeLGTXsAxauwY9SKopyC8S0DYtumb7Yzu1KUFR2us1P+nPnlkEC
         kJj4QO13XTT+7b2e/hPsX3Xodk+w3idnc2qfGGkav3qy5rOcVsiXm+uescuo1cHufa3+
         sQTYdoDCqeTXqcN6d3huXNcDgRhkdtiOk0tGd3GoU7sL8iKXGiEMFkKX5TNNUHDhtrXm
         2AyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=ftxkWchyFbaweklNC2tPHH4we0OIRk56ARBfnXFaUWA=;
        b=ygUbq6KoaxMA+zkbq3C/XxF4/yFO9+LdCMQULA22dsshMyNdXq7sksixPTE1DwYg+K
         3rcGu6gIGZDpwH546419+FOKKouJOCF4AlJbj6v4SXw+VP5gh3bwmScL6VUPlxpLaN9J
         /9KJEzbG7ZgjS0fRe2o+6SWtlFygs3nNsP4X9BomCQr1sG1oHkCEo5sJzmogNJg3FPtR
         rgJeYdy53GfoylA7MPymOmGUrf/pIUaZ4qXan2D8R3nF1O1i71kCxp/ojK1AurOoOLQ8
         sIb50bLj8xBG1BtanABS7+DvK/h4Xsz3wir6+xFjQl0ag/BtrsuKfqgGx0NSTvoyGwXX
         NNCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id t10si10253346pfi.75.2019.02.17.00.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 00:26:33 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 442KpZ5B0Dz9sDr;
	Sun, 17 Feb 2019 19:26:30 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Andreas Schwab <schwab@linux-m68k.org>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, erhard_f@mailbox.org, jack@suse.cz, aneesh.kumar@linux.vnet.ibm.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
In-Reply-To: <87pnrran89.fsf@igel.home>
References: <20190214062339.7139-1-mpe@ellerman.id.au> <87pnrran89.fsf@igel.home>
Date: Sun, 17 Feb 2019 19:26:29 +1100
Message-ID: <87h8d2ddmy.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andreas Schwab <schwab@linux-m68k.org> writes:

> On Feb 14 2019, Michael Ellerman <mpe@ellerman.id.au> wrote:
>
>> The fix is simple, we need to convert the result of the bitwise && to
>> an int before returning it.
>
> Alternatively, the return type could be changed to bool, so that the
> compiler does the right thing by itself.

Yes that would be preferable. All other architectures return an int so
I wasn't game to switch to bool for a fix. But I don't see why it should
matter so I'll do a patch using bool for next.

cheers

