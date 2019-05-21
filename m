Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B0EDC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF49A217D8
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:17:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JC7AGXUD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF49A217D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BDB86B0006; Tue, 21 May 2019 12:17:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86E0B6B0008; Tue, 21 May 2019 12:17:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75CAD6B000A; Tue, 21 May 2019 12:17:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEF76B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:17:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r75so12643495pfc.15
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:17:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Gf580EizNudcDVTEIie4/IllhBEVdC9RRaAV/oZaqEw=;
        b=AM6Z29xKpe8JbP7Vk88unk6R2gHgdtbn1Q0lgi/9z+ordZvTJyAJ97aH0I6bgYE99Y
         M0WKfWGYkNtdVrWGDq3ONwX7cEaXCaTqRcBvndeR2SYPQTzPKD1w77zTXFgDRWHquRPP
         mhi0NBkai4/B41JPHerVGdVs6OlqjA5m/U5aX9nEBHifdmmlsrrLY8u/90/gz4qoYvyV
         IzaN+uS2WHwPQUGYvlQuhN1oo44EbbEmYA6YMmJg1GcGGQml0Rzi7wNxqRbx5xsRDryx
         +3wZS/ALVYs97wGr5PM5tR0D8+844sfwOWJWjiwaEjlGpkttwoL/oFQmbNlRKMzhwhSV
         qtXg==
X-Gm-Message-State: APjAAAW+BnS6OzavaKFR8T5293VowPI/X0ac8txVuXu1SBp4eunX7sMO
	9Lb2GyI5h33g8t4ccQjQNnP12oH9MtEI9H7b2MJMmLvqAoneRPcx2blMwpz+SppQIkM01uTBtiZ
	/b+maYzQd+zu0oXjPsTzdM6FA556mjcwfuvJhD8of5DqVC+UWXe6FERxqKKV5Dg9LUA==
X-Received: by 2002:a62:e205:: with SMTP id a5mr50874228pfi.40.1558455466933;
        Tue, 21 May 2019 09:17:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6eWT2+nNdb6i6z1NMoYN4t9cViloMlDeDutJAHbX0vdfpQAYGLlsQb4UFYhlLLysC59J2
X-Received: by 2002:a62:e205:: with SMTP id a5mr50874117pfi.40.1558455466193;
        Tue, 21 May 2019 09:17:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558455466; cv=none;
        d=google.com; s=arc-20160816;
        b=jHSVyeBfRwF08ZGprsNfubRmxHsBocrforQgLb31yNnMo1K+/83Putrk5vYsaL/lwI
         H+aajDpp3zhfQJuykLH8cAvyNfFvbYrhP7rGNvouem3uP9DqaLEwpPibdiKxxQbulEF3
         Ak0/vTgcmtUVjvx7NBhc+MEFYc7jUl6PXhjeP4Lt8kNlmZv6pYgkyZuHWQHIVfAhAkHs
         zmJJoCBz7JnzB/1SQF6lr+MMJHJUNENInrhUqLX/KUT4gbWf+5+OhyPbU2iH5yb4W32r
         JFLeLMPB0Z2smYMQZHCrdpMjzi0L4WEiWit2dXwgVqN3N4D0elQbyZgrOh9bi4QYo8ZS
         yHqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Gf580EizNudcDVTEIie4/IllhBEVdC9RRaAV/oZaqEw=;
        b=uGLHA3y4vbCBhGSdDoyE9YDnkQvOScITxbGL2DffLbt5qlgYjwbL7iA4Y9rp1a5HYY
         jBp1fYGSJjrIBkKUqGyRZm25OsdPMONwX9XCdt9oBR5vYd+Ue4xomHvF5oIP5LRKj9T3
         plJhhvMbdSB71EgAStTERAmweP5wuCV6ubGzpS45iNTSf/Jm9Sp4LCrhFTaO14msg0cN
         fjWPFn3Izqy3gdtBVkvIQLAmu0VJxBXoYMnUN+hg13dYSLKRC2iaAR6VE+USwNCfD8cr
         liqtd6XLFuqotAtylS6a4mgzj3XhfLJIXyCzmWkjXLZjPSys6UYqxBEIPxeLROYVc3oG
         +IZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JC7AGXUD;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w4si20550565plz.27.2019.05.21.09.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 09:17:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JC7AGXUD;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7F3C02182B
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:17:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558455465;
	bh=Juvw2oTsl7v6zhrOBSH0qNomQ4HvlznMN/IaJVfdTn0=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=JC7AGXUDVq3FTy3A+/lXnxigcduFvb+LMxDek6FPYHJMeqK7WhIhteEBt5gTBa+ud
	 RBaUlKiedGNSLYxDH6SsmJHDQuSCToPhoHF/E6T5hxR5toqO7ZDloM0oBNwT/+jN9m
	 0qr7gPE2JJrVZaIwFLqk31O4g1ap6Uzct8C9PKeA=
Received: by mail-wm1-f51.google.com with SMTP id t5so3508938wmh.3
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:17:45 -0700 (PDT)
X-Received: by 2002:a1c:e906:: with SMTP id q6mr4280110wmc.47.1558455464072;
 Tue, 21 May 2019 09:17:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190520233841.17194-1-rick.p.edgecombe@intel.com> <20190520233841.17194-3-rick.p.edgecombe@intel.com>
In-Reply-To: <20190520233841.17194-3-rick.p.edgecombe@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 21 May 2019 09:17:32 -0700
X-Gmail-Original-Message-ID: <CALCETrUdfBrTV3kMjdVHv2JDtEOGSkVvoV++96x4zjvue0GpZA@mail.gmail.com>
Message-ID: <CALCETrUdfBrTV3kMjdVHv2JDtEOGSkVvoV++96x4zjvue0GpZA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] vmalloc: Remove work as from vfree path
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	sparclinux <sparclinux@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Network Development <netdev@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Nadav Amit <namit@vmware.com>, "David S. Miller" <davem@davemloft.net>, 
	Rick Edgecombe <redgecombe.lkml@gmail.com>, Meelis Roos <mroos@linux.ee>, 
	Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 4:39 PM Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
>
> From: Rick Edgecombe <redgecombe.lkml@gmail.com>
>
> Calling vm_unmap_alias() in vm_remove_mappings() could potentially be a
> lot of work to do on a free operation. Simply flushing the TLB instead of
> the whole vm_unmap_alias() operation makes the frees faster and pushes
> the heavy work to happen on allocation where it would be more expected.
> In addition to the extra work, vm_unmap_alias() takes some locks including
> a long hold of vmap_purge_lock, which will make all other
> VM_FLUSH_RESET_PERMS vfrees wait while the purge operation happens.
>
> Lastly, page_address() can involve locking and lookups on some
> configurations, so skip calling this by exiting out early when
> !CONFIG_ARCH_HAS_SET_DIRECT_MAP.

Hmm.  I would have expected that the major cost of vm_unmap_aliases()
would be the flush, and at least informing the code that the flush
happened seems valuable.  So would guess that this patch is actually a
loss in throughput.

--Andy

