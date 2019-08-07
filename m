Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA184C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:04:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8468A222FC
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:04:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YVf9MEhf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8468A222FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1950F6B0007; Wed,  7 Aug 2019 16:04:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 145616B0008; Wed,  7 Aug 2019 16:04:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0342B6B000A; Wed,  7 Aug 2019 16:04:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD1B06B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:04:04 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d6so53850516pls.17
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:04:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TCrKpv/9CorIIjiGQ/BTwwHa+JmbCtLDQrzBhZE1H5A=;
        b=GYtf3qbr7nUN4VIw4WKCgaHj9s2LMgCnEV5cX+KXh1XyD0X14iieVjR3TJn4bd+pCM
         yja8cJDC/RhBiKUQp6UrXnfgk7qAn8WDv9pQMtVeZZ+XcJa7CeW4DSo0QtuXIXcLNL9J
         bF266Y7EXpfhX5hNbeO2Tw+kNPvs2eO/VKPMF9gIPyP7sOoIZCvu76tc3JZguLN4cCQi
         EoyZLwC8ApUP9qe/StepaKjf0pH6tFTtyJr0zPzzar8KUAqQ6/lFSgGz95WC8VmK0ID+
         7pbl+rSRoiftjgF/8nwPEArTlTaNJUb+SIFKUgW+gxVBDJ3VIF0RAek0Fv8XA4G7U3yW
         BLNw==
X-Gm-Message-State: APjAAAWGZQzLsjXp4yYMAD7ztYcpHEuOYYV5pVvaXRfhFCCj5lGocNtV
	aXL9F/6d0LhUdEytsGXCTbZf27KSP7znFSzD5lfgtSJg4lSE+nz6GkyDSOY3NCtPvObNuY8sYNA
	pi8qvKQqzJAPgRmdlOhcwLfRONKdFjhgsx9X+nqnRv57ES0NF61CwxJ5h2bBYGGpSxw==
X-Received: by 2002:a17:902:5985:: with SMTP id p5mr9662300pli.177.1565208244428;
        Wed, 07 Aug 2019 13:04:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjq0GOV0/nAJTiR/1t2smBi0UUDNQdECRK3S98tRLR2mRsgcf87q8Ez9b7iXI4xGr8WeiF
X-Received: by 2002:a17:902:5985:: with SMTP id p5mr9662246pli.177.1565208243722;
        Wed, 07 Aug 2019 13:04:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565208243; cv=none;
        d=google.com; s=arc-20160816;
        b=QkMtuX1uSyTHgiyZkRPVN8SzuH8dc66WHv2YTWVqY3yEX1GeLO4qBVYNr7iCqgTijn
         J73NAfuMj9h7weG3c8gUSIsI4dY416JdzQSsCNVUHr04WZiSco1NQMEMeO9aPSYE4Lvo
         CbD3xV8H5t7wlNdSlESr1bl/7IZV2pqG3kos2XPeKcxIR9wAOOmp3MbqkuVLUt/En/rS
         ncAV9VbLiyi4LN3oNVlIIJNd3nlV1hlvM7CBSjy6bJPY2MZMIgh/8hMY5R05hGIY76D3
         uBZRyEuDvjKxxO/VpDK3QGCR51RsbzoGkRHbqCcef3k8DCase5ti0bmw44jXjj59XwwR
         Z9ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TCrKpv/9CorIIjiGQ/BTwwHa+JmbCtLDQrzBhZE1H5A=;
        b=iQKILhBzVFqfsuJtsAp0Jw6ah6GFene/NK5eLBfMZ7C0YpX0b3tz9a+06hpE7hFyJp
         zXkFBVzftNB4gl+z1KS9h9kJH9Hhujpq5rJAQJwPcm3XgYpW3UZtkc03gz0qfQtQGymy
         zZs7+Q7qcTLz9jsGn4XzGRFqIUR8WlSx072dgiQdFob7Tz9KSYS2MSCn3uv2abovvMSb
         kHqoK7RTamWCtnDtCl+OI39L1NkN//2YgHuirpM1bExV+y0KWy8gvgD4vwk6DuvtODLa
         xyA+HQbjVcHlSyFhi9qfM6BvtEpTV85nmNekCzJE/uPiOVres2vSUX5XEwxaE263Vili
         pQhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YVf9MEhf;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id ce10si2566272plb.180.2019.08.07.13.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 13:04:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YVf9MEhf;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5A4402229C;
	Wed,  7 Aug 2019 20:04:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565208243;
	bh=bAnZKDOHa6S/AueqvOn27z8E6ylUixYsDkIKVgnZVKU=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=YVf9MEhf32W89lIFkjGgA88GCVZUVwxfcFmTKmPUg1Q1y6FDrsnr0QeqCQi2SxSAj
	 boCVYX0PmLYKtZPc0GeShN1mYQGBwDMs4u3zZmSSnElYlW9VIKtGrr+WQfA7EMdUZ7
	 l8JiW40t7+5cKUXM2gftIZQ0r8IJhj4wMos6tTo0=
Date: Wed, 7 Aug 2019 13:04:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>, Catalin
 Marinas <catalin.marinas@arm.com>, Christian Hansen <chansen3@cisco.com>,
 dancol@google.com, fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, joelaf@google.com, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 kernel-team@android.com, linux-api@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Mike Rapoport
 <rppt@linux.ibm.com>, minchan@kernel.org, namhyung@google.com,
 paulmck@linux.ibm.com, Robin Murphy <robin.murphy@arm.com>, Roman Gushchin
 <guro@fb.com>, Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
 Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com, Vladimir Davydov
 <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon
 <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-Id: <20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
In-Reply-To: <20190807171559.182301-1-joel@joelfernandes.org>
References: <20190807171559.182301-1-joel@joelfernandes.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  7 Aug 2019 13:15:54 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:

> In Android, we are using this for the heap profiler (heapprofd) which
> profiles and pin points code paths which allocates and leaves memory
> idle for long periods of time. This method solves the security issue
> with userspace learning the PFN, and while at it is also shown to yield
> better results than the pagemap lookup, the theory being that the window
> where the address space can change is reduced by eliminating the
> intermediate pagemap look up stage. In virtual address indexing, the
> process's mmap_sem is held for the duration of the access.

So is heapprofd a developer-only thing?  Is heapprofd included in
end-user android loads?  If not then, again, wouldn't it be better to
make the feature Kconfigurable so that Android developers can enable it
during development then disable it for production kernels?

