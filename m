Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AED79C4151A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:03:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 460CC2146E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:03:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 460CC2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B34D38E0003; Fri,  1 Feb 2019 17:03:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABBCB8E0001; Fri,  1 Feb 2019 17:03:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 982518E0003; Fri,  1 Feb 2019 17:03:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 650268E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 17:03:49 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so6717078pfq.8
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 14:03:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2BDC8irRybwaPqrOh4vhRqpsOVNsgly5TVq7dlUUD4Q=;
        b=I9GivB3/CxhXnvPtxMF86JvJw1XwT3qtp85DtEdT9QihGT6o/HtQSY+ncKmMHQiqSK
         U7NKxXTmmN3Y57WE1VMpFE/L2NlFRhafK31+bWec7TuyA2e6Wvq21il8Cp6r8nc0GLOD
         UAACvOW7DVkl73WsmdFsyeT1KNeKZ2Me7SujtlreHP9ZsYS7HkXpCAxdefse1Zhw4Toc
         HWjDygOC0dsXoyfUfReWnTHijLEp58xSWYyq1c0J5nLplXC3Jrx9/4Kr2PfU1ck5somt
         S/r44SCZcFHY1Ul/YUiax60A+jSrmQkx9j00riS+63z0DlWIRES9Wgl28/JPtW4o9x4E
         Zt8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuaZ0OxPbkog4qcg4JxcLu6N9Xt2X3/4IeLGo/iUkHweU1KVdpNQ
	nv1j2UY+gqiAOoDF9tadTV8UoTUjqP8N0LFS5GIbWSNBic6qrP5RmV5oR6J/yEKxa7VCiuSU7tq
	dyPNXRz5nPRZiyqKv+bpKmitBo9nnYO5GG+D4kHdV1qeln8aez4zA7Heb4es2UD8PCg==
X-Received: by 2002:a63:4002:: with SMTP id n2mr3930389pga.137.1549058628921;
        Fri, 01 Feb 2019 14:03:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZdwLixA3Spc4/WLFxz/Kl+ci5UMMslRSMS5p1kK2N2/azKp8FVhf45EW7xQ1IB52dLqpiG
X-Received: by 2002:a63:4002:: with SMTP id n2mr3930343pga.137.1549058628307;
        Fri, 01 Feb 2019 14:03:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549058628; cv=none;
        d=google.com; s=arc-20160816;
        b=SV/0QqGdUFgvzxt5VegfKBIXLW0o0d7TyFkaMlcg/dnGLb9VLyUIwROJHTowLuBj8D
         8Rai2lqlLQ3+6feoyBO6TsJUT5w1V2bRbFzfYF+pnrfscizgpn0t6+tbNb1nJpfOPyZQ
         VJWpdGGdiZ3+CulM0V57nKu0If+kLp26Xb+BlqWetNA2Yu3ZwC3tPOtRvuXFUkLVjxsp
         5luWwLJyKiMwVc9G0W9R3K4YCXWGBJCWgKeziarog1RK7Mjie5Ki8qc6zFXyw+thIHYc
         +VcLgnebmtCQdUPNcC152oh2XA8PXG+JW7u6f91H+qTdIg8JL+ErB0mcFvTPvSJrGWCq
         MvXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=2BDC8irRybwaPqrOh4vhRqpsOVNsgly5TVq7dlUUD4Q=;
        b=IC1OUD4URPaZsObOOh4SMhB2yjsgLPIoBGRmuPaQwvzCsfswiH73e7r6XWluOsBBTE
         r1FU11mSE1BIScUjfVYsfdogpE+oxZ59PeMOapKtUCLXLgicHgYScVyj6OkTpYLibe3u
         QZZ5vb3LyLIQ3kEZ1Re36gZl+Iwi4Fm39cb2qNKb7RBRr8w+qiAhVOoyg87aKG14GezS
         w0nGPaJh2KZTOJrX6UkMGlSOCtsskcIXIXG5MDk1acerIfXT7i2tzLeThcxGPZX4Cmj/
         9TuiOnDiLoekt4M+g1dtrs82tefvl+B5SrgCpxlp3+wfWViJugh5FpN1w1xBjf6ssw1K
         edXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r59si8014937plb.247.2019.02.01.14.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 14:03:48 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 8E7CE7D25;
	Fri,  1 Feb 2019 22:03:47 +0000 (UTC)
Date: Fri, 1 Feb 2019 14:03:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-Id: <20190201140346.fdcd6c4b663fbe3b5d93820d@linux-foundation.org>
In-Reply-To: <20190201024310.GC26359@bombadil.infradead.org>
References: <20190201004242.7659-1-tobin@kernel.org>
	<20190201024310.GC26359@bombadil.infradead.org>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019 18:43:10 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> On Fri, Feb 01, 2019 at 11:42:42AM +1100, Tobin C. Harding wrote:
> > Currently when displaying /proc/slabinfo if any cache names are too long
> > then the output columns are not aligned.  We could do something fancy to
> > get the maximum length of any cache name in the system or we could just
> > increase the hardcoded width.  Currently it is 17 characters.  Monitors
> > are wide these days so lets just increase it to 30 characters.
> 
> I had a proposal some time ago to turn the slab name from being kmalloced
> to being an inline 16 bytes (with some fun hacks for cgroups).  I think
> that's a better approach than permitting such long names.  For example,
> ext4_allocation_context could be shortened to ext4_alloc_ctx without
> losing any expressivity.
> 

There are some back-compatibility concerns here.  And truncating long
names might result in duplicates.

