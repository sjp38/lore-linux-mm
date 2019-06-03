Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B8A1C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:05:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D12E27C80
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:05:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D12E27C80
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D56F6B026C; Mon,  3 Jun 2019 03:05:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 985E96B026D; Mon,  3 Jun 2019 03:05:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84D5B6B026E; Mon,  3 Jun 2019 03:05:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8D96B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 03:05:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z5so26155327edz.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 00:05:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=EM7o9Os3M5DtwAMRoFNvFu9547v4JOKUzUUCVl9kaHk=;
        b=MzAkTNuzWbYwVTVo6unv6aZ2z3kzHEMyDp7zJUdas686oT8AQLFHAfdQBcHHfJ+WY1
         yCVuDWXRWElLYA4udT1GSzhwQTTVuL6OGaejXEUzcREc3tErmwksEFnXmUwZFa4JVZ99
         JlywTGGLPwIQBlvCG2i8McKUK8xmiPvPK7YfxzPU2wKJD+Bm2qcLY9lZLI5mJKlxEQaA
         OSNezDFvJ9N4+MwU6ifn3HzFYHsTn43mgqseKCjqf3Ks9GUl6ZImqIiXXY3+l9Gxz7dU
         v/4Dq/DdY0sndgDqpv06Ms/WczlQ9YiuvIcVikHsCYinHIXRS3L9D+VYktaiB44HFOqI
         PMJg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXkUbfzkMrU7J691URgcMC7I+iEK1hG7zkFXt0kACyY+oaOxVJ1
	Usx7+dOpRkOQAJNN/DDoZcZQsxnx5d9h+Z7lE+bkRaExOvzu5CUpdB56K6OU+tko6JuOhlIgxt8
	PsvL7AHlU28wQ8QZpqdOlkeIGc+Zho7cDsSsWyVwWvc77m2s2CV54w61ysHIbN3A=
X-Received: by 2002:a17:906:2a92:: with SMTP id l18mr22267865eje.181.1559545550842;
        Mon, 03 Jun 2019 00:05:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyX9eEXw07iFj74DGoD/vvoVz3aWbP3bQsueYoZR/VzOMZ0bSupd/ATW9JcIhpxT5pmB1q+
X-Received: by 2002:a17:906:2a92:: with SMTP id l18mr22267806eje.181.1559545549969;
        Mon, 03 Jun 2019 00:05:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559545549; cv=none;
        d=google.com; s=arc-20160816;
        b=GIwsxt/Lr43u7R7ZAysdgCFyuQ7bjz1AALpnFYXLvuBE3Zt5EEanSdktqeke6ZMRFe
         bJ8VaW3oOXJAtiRX/k+PR4FZmsK+kv7xfMxisgbT+CgOxykgAsg9K+MkzlLGzU3RZ9PJ
         lvTi7K0cT0baMNUs1bja3xz+xN216c87WSK1A2ZltiAEcrC7xXmuoBRSqv/Y6yaO7lTD
         L0fvLYv0wKhH9WrJcHSNxY2EdU2RsvIiyTalPeS0tPhZuV3q679qi792RQPKBhBlz6td
         yWLtioZXP05NbfaUE3qYivXkn0TZVC7guaVE0ye4pkNGrh8E5m+moRIG3Ukrqcp5qW0B
         jWMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EM7o9Os3M5DtwAMRoFNvFu9547v4JOKUzUUCVl9kaHk=;
        b=t2F277FkOxPwsg2PPvwwcW1Ool603jFKfCZtPheodkEB368ug2O1QM8tx7+Fp9KM/Z
         rBG3GrrjDLTBwRhvpA+gU9jD1fqAhtHVDdJ2giEzjbNGnVozBLdXuAfiXAhd+60Wy1/m
         XwXSvoGC5fj7K9KpbBVLappKqyRfI3OLZbZZ+aLEGGhKvxE+HghXQBRZzT5zjjhCgU9F
         D1YJJWSyLvoWo55AWXHCRu9OiPVAzqpxkN9rAGTzbPorett/qpkLi+ekMYJdNpSUKKd/
         XTOTOsq0f9+O9MQ9AucqHdBYZj5Iw7ePEewiUVg3iy5MubB87Txsbtgo7msX1FFFA8e+
         68dA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id e45si7831278eda.383.2019.06.03.00.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 00:05:49 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 4D6CA1C0002;
	Mon,  3 Jun 2019 07:05:37 +0000 (UTC)
Subject: Re: [PATCH v4 05/14] arm64, mm: Make randomization selected by
 generic topdown mmap layout
To: Christoph Hellwig <hch@lst.de>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Paul Burton <paul.burton@mips.com>, linux-riscv@lists.infradead.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-mips@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Luis Chamberlain <mcgrof@kernel.org>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-6-alex@ghiti.fr> <20190601090437.GF6453@lst.de>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <211c4d0b-ec11-c94e-8a7f-9564e7905f50@ghiti.fr>
Date: Mon, 3 Jun 2019 09:05:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190601090437.GF6453@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000993, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/1/19 11:04 AM, Christoph Hellwig wrote:
> Looks good,
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>


Thanks for your time,

Alex


>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

