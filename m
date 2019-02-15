Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89E15C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:43:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FE53222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FE53222D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BABF8E0002; Fri, 15 Feb 2019 13:43:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 842DC8E0001; Fri, 15 Feb 2019 13:43:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E49D8E0002; Fri, 15 Feb 2019 13:43:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29DBE8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:43:29 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a26so8126329pff.15
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:43:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lXzZQDiLj+YlSMM74+Z82ZwxGcRsCJXxK7Kp+nLjY6I=;
        b=o1M7augwQH8wR87hKaeMixyRQvl8Zm9b51vZlQ6HnQUD1vMe8clN0etC4tC7uG4Gg5
         BRN42zlsBH38IHTnzhirjNIzVRY2FVPWh5N/LZmhhpe9KkilSOeHwlBQjnmoaqjnWBZs
         kfZCsrPi20FySkV1UDsQnlh2rbtIsYhm5w/nrssSHTnblAicJApQXPjCmJ9Z8vnDAWBW
         BZTxfLLndoMicsxcgB/DsoKOhzvQS/0C2cq1vaEWvUznmGbmhl/t7OpUJAIp+h2VE3jS
         4bMJjiX9wijE2ZCqcQP8I2HbzzTvLG/ud9UjwgVALh/sciNj4jlBr2LtvxFYzqpJX3r8
         oSuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYOSPF68Yae53ZMJyQGjTi5KLYRRq0trSRCNCQ/BmuEsW6NPnCL
	85PFjmGlEXqbPSc1DUiuRR1OvgBky3LpSdvd7wM7c/7xeWSq5R6hzcwLFnoPKaRI43q1FnzVqnj
	Bu5kYjTrcyDHNfH/pHafQvcTsdOM6f4ram1sMOL8tJ4U0gMa8PZG6SnFHv5OJbdtlvA==
X-Received: by 2002:a65:6542:: with SMTP id a2mr10469583pgw.389.1550256208778;
        Fri, 15 Feb 2019 10:43:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iah67AI1xonMvyvbZg2IZjNqszGs+UbjYRxjheWqz0qRATrbQmwcrEAruQmaIJ7OExXzD/k
X-Received: by 2002:a65:6542:: with SMTP id a2mr10469527pgw.389.1550256207893;
        Fri, 15 Feb 2019 10:43:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550256207; cv=none;
        d=google.com; s=arc-20160816;
        b=KzwhwBeR7fAQwdV1LJZlwNVgCdvXR2RQEOvXU4fgDZc58zlJkjVvwKUdWEteCHB7i0
         YwzqzphagCey3ZR8aPEB6ZqZ15zGtVXvZ5x55ojbuCErJjnu4vGMiw8nW56VqmoF6VYN
         jBbrIK9rRdMEfQqSE+vwZUobODpgDumDF7DDOR4YVmUJwwAH2wc5046SO+QitrNl+WeO
         epKZlpdxEzUJ6R5QpIAiAWWuEkio1f33Xa8lyB6zZP8t78jKW+GAHsRpHs7e2aTHheHi
         w7mEIiun1bU5TayIlIb+zzSG+uWsd4uDhxL8g9jZ8ej9fqGatsxthzygYxbszOM5ZyYm
         dlaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=lXzZQDiLj+YlSMM74+Z82ZwxGcRsCJXxK7Kp+nLjY6I=;
        b=XEv/zMlfJJra/qVIceMoAqIi0vud7Si1nZnLqXK7B8/A06fJvOGrRtXWQsV06wAqwK
         nHQBPWMKQ1GRH/BcURl4b1z0uWch47cMCQ8hjmyxhxKHAYavM6vYmuNg3MMS8eqg8xf9
         Y2cyUa85sGJXBsaL0NiDEjsfoFtrt7H+ZseIimvEwlHgUxAIZMI36Q9G3XMli/9rI6kY
         LRgvB88AiRJgWAKlDK7RWe8pxPk2DqBFNQdIlx1c1bq0Pm6XgVKfKZOwqHthd2tvjZ+9
         RnYHVCWu5zNh6GZcppPlj6cUl0nx44n/DKjSxkuaIaARd4XY0ZUxuNRa5dJO+G6LLSSq
         XCYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m1si6006783pgi.218.2019.02.15.10.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 10:43:27 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 82702B1D;
	Fri, 15 Feb 2019 18:43:26 +0000 (UTC)
Date: Fri, 15 Feb 2019 10:43:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "kernelci.org bot" <bot@kernelci.org>
Cc: tomeu.vizoso@collabora.com, guillaume.tucker@collabora.com, Dan Williams
 <dan.j.williams@intel.com>, broonie@kernel.org, matthew.hart@linaro.org,
 Stephen Rothwell <sfr@canb.auug.org.au>, khilman@baylibre.com,
 enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>, Dominik
 Brodowski <linux@dominikbrodowski.net>, Masahiro Yamada
 <yamada.masahiro@socionext.com>, Kees Cook <keescook@chromium.org>, Adrian
 Reber <adrian@lisas.de>, linux-kernel@vger.kernel.org, Johannes Weiner
 <hannes@cmpxchg.org>, linux-mm@kvack.org, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Michal Hocko <mhocko@suse.com>, Richard
 Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)"
 <peterz@infradead.org>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-Id: <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
In-Reply-To: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:

> * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
> * This automated bisection report was sent to you on the basis  *
> * that you may be involved with the breaking commit it has      *
> * found.  No manual investigation has been done to verify it,   *
> * and the root cause of the problem may be somewhere else.      *
> * Hope this helps!                                              *
> * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
> 
> next/master boot bisection: next-20190215 on beaglebone-black
> 
> Summary:
>   Start:      7a92eb7cc1dc Add linux-next specific files for 20190215
>   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
>   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
>   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
>   Result:     8dd037cc97d9 mm/shuffle: default enable all shuffling
> 
> Checks:
>   revert:     PASS
>   verify:     PASS
> 
> Parameters:
>   Tree:       next
>   URL:        git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
>   Branch:     master
>   Target:     beaglebone-black
>   CPU arch:   arm
>   Lab:        lab-collabora
>   Compiler:   gcc-7
>   Config:     multi_v7_defconfig+CONFIG_SMP=n
>   Test suite: boot
> 
> Breaking commit found:
> 
> -------------------------------------------------------------------------------
> commit 8dd037cc97d9226c97c2ee1abb4e97eff71e0c8d
> Author: Dan Williams <dan.j.williams@intel.com>
> Date:   Fri Feb 15 11:28:30 2019 +1100
> 
>     mm/shuffle: default enable all shuffling

Thanks.

But what actually went wrong?  Kernel doesn't boot?


