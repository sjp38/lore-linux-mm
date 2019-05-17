Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91B31C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:37:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51B532082E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:37:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zyaA/h6a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51B532082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D86FA6B0003; Fri, 17 May 2019 17:37:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D38C36B0005; Fri, 17 May 2019 17:37:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4E2B6B0006; Fri, 17 May 2019 17:37:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB9A6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 17:37:48 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bg6so4924644plb.8
        for <linux-mm@kvack.org>; Fri, 17 May 2019 14:37:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8gEh3e4sCXemcPk2Uur0pjeXhCScach2WX84NIsTDx8=;
        b=c2JOvzIAAflPZuVkkctR6J0cpHoMlFL6IWXe90lSiD2cyoNP36JQMMLMkK/U9LCzKN
         xfTPtkwE3x+EO/UV8OmScam8zeePC1j7YOp52HvBgh9e6TpfwqnOeRfqn8SJkD5Le2Fr
         PhJFUGJgizwzJnNRHdGjZM0W5alfsNXvwIj9RAF/RAp6Av9Boru4izyXHOl4lz+7ZpNr
         8zXUgCVwAraaSW9f5CYhIEDunGjjGL8vSavI1TB2tML0lxbncodlNLnS44LuvnIGds1D
         g/oNVFJkSC5GATPrSXqk22hqOkHfoho/4liMA1JZXmxNjypaYaP0h/0096g7vlNBGvND
         CC3g==
X-Gm-Message-State: APjAAAXmCWSlYxq/BwzYsIzSMcZUOPgK/aYjlnezWAy+mP0oAGF/+Gjz
	EPMfXR+3cFTXP2jQtc0ZR1TJc/FypDFVP4W5PXT4UtKejQgoU6/4xyTDNJVuTgK+/iIBCEFZLBk
	ljU4PR7wFJN/B4NUK0ls7O50GcneR86WYaihMNXqhNPa2Eu9skuZNoblwdCx4C9DmbQ==
X-Received: by 2002:a63:5c1c:: with SMTP id q28mr58432076pgb.45.1558129068265;
        Fri, 17 May 2019 14:37:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8pJscQ9o9PjA0qWdxWzcfpQr8UUlE3xvVHZ3eeUzG2nzYGHq8zA1jAkxRvGAtP7iCDojt
X-Received: by 2002:a63:5c1c:: with SMTP id q28mr58432035pgb.45.1558129067557;
        Fri, 17 May 2019 14:37:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558129067; cv=none;
        d=google.com; s=arc-20160816;
        b=TQqMfmwyxyc0qosHtNqaLTknLEVlK/nfOGvZwXi6CIqzYz3PiyGcwL44wf/LLvIHVe
         RKVRVyb5H9QilKJfx1w3AJGCUZ7m6/SUiImkOfWr7JUp9KrZVy2sOSs3dWKGIPLvEdGg
         5ygaTRSJR8SwIYHLGAcoY5Cg+My2GEnSSZLw6Q1KSWPtixUHFOVA2IwXqrCAvDFRR068
         hDQg53AnbJC9hf9OQr2UySnQ5j4WzKEJA58msvAExTvLgT54uS0PpBgcsfDztuUpHcin
         5M3N5n3kThuQoGjQVZlwv6+0NV3pXtdpQHxMutf8k0aHLNM39rcII95atHAOzvtL0aVt
         p4QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8gEh3e4sCXemcPk2Uur0pjeXhCScach2WX84NIsTDx8=;
        b=hOyZSmqpanDwDZYZ8yvtnBuQrxT2PSiYx2D1jei5zbeQBN2aZnYNYT1Q2V5NPylErM
         zGvi+ITsY+D0kGf8optDMjZkhhYTJo4Qjq85eFIJQQEK4JAefJEvEybFtuB19gVZanTb
         4huti1Wr8zzG/8jlNJEyCwKgYPeV/nGOOyooS/8gsfLORIdVxLrTxvIl0kfWIdH6XETv
         qJEr+vDho4HA7BiQL5PXUL1vKGDBIQlci2dYRyFu8NzWAfAzgcOFoMipvKVGNFYbvY8R
         I3ytuVTGVhhY60OsikxIh2iXrCDZV9YqC7NxwRdTtZFAMc9X0SD7gxsaaC6Y2KSRnVpU
         hb7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="zyaA/h6a";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cd5si9458713plb.207.2019.05.17.14.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 14:37:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="zyaA/h6a";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E79DB20815;
	Fri, 17 May 2019 21:37:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558129067;
	bh=aV+DZYgCxz6TeUuopFM95pRHxHKcPxgDyN99N5XYJko=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=zyaA/h6aSWnQbfVIYgqsy2UrDKSlqT0fUgWvQgq/rIbENLvBDNuAhY84I4Cm0CmLD
	 cPGqFAtx/nnBYevpcWHQItaMk+wpufHLo0tSppdBJA4ooerLdUqPl1v/gMovZc1ya9
	 Y/ZZQIjHjuO4Er8F1QTdG0soYL1cGA93941vJyYY=
Date: Fri, 17 May 2019 14:37:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dmitry Vyukov <dvyukov@gmail.com>
Cc: catalin.marinas@arm.com, Dmitry Vyukov <dvyukov@google.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] kmemleak: fix check for softirq context
Message-Id: <20190517143746.2157a759f65b4cbc73321124@linux-foundation.org>
In-Reply-To: <20190517171507.96046-1-dvyukov@gmail.com>
References: <20190517171507.96046-1-dvyukov@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 May 2019 19:15:07 +0200 Dmitry Vyukov <dvyukov@gmail.com> wrote:

> From: Dmitry Vyukov <dvyukov@google.com>
> 
> in_softirq() is a wrong predicate to check if we are in a softirq context.
> It also returns true if we have BH disabled, so objects are falsely
> stamped with "softirq" comm. The correct predicate is in_serving_softirq().
>
> ...
> 
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -588,7 +588,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>  	if (in_irq()) {
>  		object->pid = 0;
>  		strncpy(object->comm, "hardirq", sizeof(object->comm));
> -	} else if (in_softirq()) {
> +	} else if (in_serving_softirq()) {
>  		object->pid = 0;
>  		strncpy(object->comm, "softirq", sizeof(object->comm));
>  	} else {

What are the user-visible runtime effects of this change?

