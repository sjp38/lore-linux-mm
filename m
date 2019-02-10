Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B26F6C282C2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 19:39:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55172213F2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 19:39:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55172213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B59C38E00BD; Sun, 10 Feb 2019 14:39:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B06C38E00BC; Sun, 10 Feb 2019 14:39:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F6348E00BD; Sun, 10 Feb 2019 14:39:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 591F58E00BC
	for <linux-mm@kvack.org>; Sun, 10 Feb 2019 14:39:56 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id l18so4812027wmh.4
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 11:39:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=QO3Z0vOdGNa4Bgr83ZCmIOhuWPD5CZaXR4TS+JbfVms=;
        b=mGEkgRBLbWVIVRtkr4j+ZihMyGOcD3UNm2iMeqSwNdYFYvt5JJePhZBtQouLQNQoQk
         ENQfabLz3dmrbFlAb9ixdb2AhFxFyfmausg6UiNMXgwO5i+pTCsHWO48MIQ/iwZfv3sC
         JQNq+y6gAAbY1YnV1SMcfi3mE6zzxbMTP5TEYv1z+QtM92ZBzhEblVrjOJplerH5Kaxb
         OaRxkqb6bwfbed5Qo1I5q6LLKI45y72lEXSRTBvDTgEcYAHyKcIOTylp4JO4JvLFhYoB
         QAR+SdhSPyzMr9rscFc8jkw+xmFa917Vv4uMg15ox+NLusZAei8Lj86LZxEokBMikoTe
         Y6qQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: AHQUAuZZ8y3yRRvwGL59or6DlH2LIyYLTUFzxJWEBKs8t7zeEaR9hGeW
	1sx6NhIWqebjzV45fuLhOfUUzh573ostVkprbBKUgt53caQvhsLMiN7UmURDaxkCtO88mFzANho
	daKyuU+MrleDJ9SqRn3Wj01jwuHXxta8dN1CIRm98gdTUbSeihL5rni3x/HGjHExHnA==
X-Received: by 2002:a1c:f50a:: with SMTP id t10mr4069883wmh.126.1549827595833;
        Sun, 10 Feb 2019 11:39:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYfKbrYjfAwO3CSH+lFamCHzLtWC/wIvjRSX74qV5Z5BXjpZuS28Lg5eaN1/IAxj5XBIXIf
X-Received: by 2002:a1c:f50a:: with SMTP id t10mr4069847wmh.126.1549827594821;
        Sun, 10 Feb 2019 11:39:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549827594; cv=none;
        d=google.com; s=arc-20160816;
        b=O7DEyGNC/hd/x2t7+USe6sjUsGTEstQ5KBKhnZDf4wgfaRCEZ4tVrGHWP+I48dJxfO
         sWbupX5kQpUid+zVtSUF2PEKAjFZ3O2rJtWn9LT8451oBuDWd+M2dH0Bxa0Bty5UICC7
         8OjyX7IWqWrdA8fq58HRToPCSVCDgsey6x+OONT7m32DZCv2thVGnAoPsSEZHzeG/B+4
         PGDxQeZ6POmG7bitcBQk2DWgGiz6pj3BTVOH1D3loMovoUXscYGw+zkOduBF6NQCeDw9
         3LlR9Ui1InbIJN1p0Xu8S96fehXD858Y+Q830McqyTLksD/P4fMzkVlSAXlZv3c5pIio
         uAkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=QO3Z0vOdGNa4Bgr83ZCmIOhuWPD5CZaXR4TS+JbfVms=;
        b=pFch3fYRPZRS68OrK8ZeoywQzCc3tYRRbs4J0yMvYTv6jY/jJfftcqrhVkhwf5X0kK
         cs5Hksaxbsix0QWEw+PVXlqQY+F/LzF2+gzKcb7PrP2vuq0YQc7PZ23nsJ2gby0bohK+
         WU/BAmft+LP/ubCl/SUP+34T5B6C4GJkayDpyzZWdiU8vB8Nsk7z02H1rc8FQHZhwjdP
         9hTxZcKEp2ljpcUvcKg9aWM1MicA0al2VcE3/Cr91gi/Xw2715cZwJJ6bhHgWRwNUuzH
         WhGk0mvlgjLgI9+OKJnav+xYACYQfurz+9cCG+dtYmZNdlDGF04c2S4e/AWfQjBCkbbk
         nzDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c126si5678133wma.194.2019.02.10.11.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 10 Feb 2019 11:39:54 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from p5492e0d8.dip0.t-ipconnect.de ([84.146.224.216] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1gsux6-0000J7-Mf; Sun, 10 Feb 2019 20:39:44 +0100
Date: Sun, 10 Feb 2019 20:39:44 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
To: Ira Weiny <ira.weiny@intel.com>
cc: Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
    Dave Hansen <dave.hansen@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm/gup.c: Remove unused write variable
In-Reply-To: <20190209173109.9361-1-ira.weiny@intel.com>
Message-ID: <alpine.DEB.2.21.1902102029560.8784@nanos.tec.linutronix.de>
References: <20190209173109.9361-1-ira.weiny@intel.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Ira,

On Sat, 9 Feb 2019, ira.weiny@intel.com wrote:

nice patch. Just a few nitpicks vs. the subject and the change log.

> Subject: [PATCH] mm/gup.c: Remove unused write variable

We usually avoid filenames in the subsystem prefix. mm/gup: is sufficient.

But what's a bit more confusing is 'write variable'. You are not removing a
variable, you are removing a unused function argument. That's two different
things.

> write is unused in gup_fast_permitted so remove it.

When referencing functions please use brackets so it's clear that you talk
about a function, i.e. gup_fast_permitted().

So the correct subject line would be:

  Subject: [PATCH] mm/gup: Remove write argument from gup_fast_permitted()

Thanks,

	tglx

