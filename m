Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 239D9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:58:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBE672080A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:58:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBE672080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69BE78E0002; Thu, 14 Feb 2019 15:58:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64AD88E0001; Thu, 14 Feb 2019 15:58:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 588B68E0002; Thu, 14 Feb 2019 15:58:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 287018E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:58:02 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q21so5711091pfi.17
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:58:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/uMjKCWhWc29kS9ZB6JCV38fue/y6kX3dL+O2slXMpg=;
        b=O26u3/b9THfs2/3MoJeI73itJS8XJ3lB9mZDBaCK18V8B9rE8hWf/2TUuN9somkP/i
         Z8n5xt7IN2Zqg4zFW1ah/spu3hrH09Yqx82x3zxf9OupIa88n/VSxh0f4XJ7Y5GmTRdC
         1nj3UAR9AUbe6ojg7GJJMmHZCiJE+vDoKy5aoEnOrM4XXifihqTknYIOMwDLzHB16rKf
         /jaRMP7FpZzYGrOi7j0fP2KpvKuj9OpIwghYBRHg494CoZ8BWtPff/cV0pu0G2/a16sY
         mZzyDfVFFBwLhR5HFFFazPuMQE15cFSXDtkbA32Kih0RQVLnmTsZzmqgSpIexYM01tlc
         o0PA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAubwRNv0Q1x9cgKXzUKMFq+rvhhv3LjgDIUGNq4QWJWXV+vTUPiE
	k1QIK/KmrrChgUjQdBLNZLpDB4ggooe6ffDKao9/z5jzZ5Mqmc0+G8MayfLwJNtgGsl0Ykd1Tig
	j3kb2QonIchEPiCYFXGhtjI9WUjenW/NSL5XyovJVneps2CdhO1kgOxZGqlgy141viA==
X-Received: by 2002:a63:1013:: with SMTP id f19mr1832564pgl.38.1550177881847;
        Thu, 14 Feb 2019 12:58:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYeuMCB5DGevlyWb7KjwrTiiwN3X66obLcKCTHzQ5AfV4k8fwFERG3kpnpr2iqywYSbNhTh
X-Received: by 2002:a63:1013:: with SMTP id f19mr1832531pgl.38.1550177881258;
        Thu, 14 Feb 2019 12:58:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550177881; cv=none;
        d=google.com; s=arc-20160816;
        b=vDXlUtgAOzmHq/S5Ox7poNK6ABM5pdRZGz8QuKW8biXN3jqxMXfCR+yUSAml4HDDhS
         MfnQXUJ7TIIyJaz7MhwV6FQBkHOsZFU6Y8p7MzDnodahHYnSQZBIz6uZXEDPbZEflFZC
         u7oEoiOxehWrokWpX53gFKhFmICADeYLKslP0qFvMtLuBi4Vg3npvTm8Gj3JTvcfKSQE
         KuHwb/ImpU66GRmTb1/rIkSVktvmlq3K6iWjFZYLvqghmQTHxRkDL6kNx/kwdx2AhQ/3
         OSignl+M4qaWuoO3qLeSV38+1//v+iMERj1Ox+c8K3V6zYIVNerLmPdKdTWVqFu4SWAX
         Kynw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=/uMjKCWhWc29kS9ZB6JCV38fue/y6kX3dL+O2slXMpg=;
        b=EyRMFWM7Cbeh4a6ML9D9SmpoxB+ZZ9WKUqqlRT0cEb+oulmQ3kN1rnXm5Ayl0BkfNN
         neXyu0E4HMJk2HsCDeiHyZ0E8KrQMcqGWXE1BdXsQS5QGxNL4hKCqrjnG23uwaRrTsM+
         dRthPjh4VhXUSzd9hJw1VCzVDtFC5N2citiD0C/LH7JQmU49PUoEQ9Hn8l+IYWsP2x9w
         xwaKShh2bur/T2p5/X126A64v7HLRSTcHuORUwbzkMXA9ccZAgbub8Jhxab5plCGCzNu
         blrDYoc40f7QWYwyGwhcWizQEYi5lZ26TrnSEwZjcPkRTuQSmspe44iv3GCU+PT4TKAI
         hBSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w4si3388511pga.148.2019.02.14.12.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 12:58:01 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id C448CAC7;
	Thu, 14 Feb 2019 20:58:00 +0000 (UTC)
Date: Thu, 14 Feb 2019 12:57:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: daniel.m.jordan@oracle.com, mhocko@suse.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
Message-Id: <20190214125759.97558dd947057db0397eb95e@linux-foundation.org>
In-Reply-To: <155014052145.28944.16497030123804725057.stgit@localhost.localdomain>
References: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
	<155014052145.28944.16497030123804725057.stgit@localhost.localdomain>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2019 13:35:21 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> Currently, struct reclaim_stat::nr_activate is a local variable,
> used only in shrink_page_list(). This patch introduces another
> local variable pgactivate to use instead of it, and reuses
> nr_activate to account number of active pages.
> 
> Note, that we need nr_activate to be an array, since type of page
> may change during shrink_page_list() (see ClearPageSwapBacked()).

The patch has nothing to do with the Subject:

reclaim_stat::nr_activate is not a local variable - it is a struct member.

I can kinda see what the patch is doing but the changelog needs more
care, please.

