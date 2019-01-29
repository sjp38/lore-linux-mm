Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85538C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AEC1218A4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:16:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="g5iG952b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AEC1218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD03B8E0004; Tue, 29 Jan 2019 18:16:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7E778E0001; Tue, 29 Jan 2019 18:16:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B20DC8E0004; Tue, 29 Jan 2019 18:16:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9F48E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:16:03 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y6so11618399pfn.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:16:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:in-reply-to:references
         :message-id;
        bh=9u+YV5IcvYsQJ8cY1MX2zpgFq03ogjt0USJCUCHFOBI=;
        b=N8CkHgPB1qi96uW5ONA1htW0DKVpQ9loeN45FnCYCFEdcd8wxmqHA2Zdb5IltKe+kP
         sfH3J1ccDVbKFFvCKaOOhFZDqdeX0gGAGjb6JiFTdYjmDuYYpt7XKrBuloYIZb4Yi6v4
         /22Sv/DvLkYHeQ2jaH4o1t2alOT/3VIrmQvX49xHcsQvzoBfnyeZI/yOuiNaoagD9cXv
         NOw7dHsrYf339FvesO+5FCMj2MaSzL87g0RCRGXXZGmOD9Q+J9UwRg4DrGZANANN0Jqa
         udEN0V0bP18aNIJjqQHKeS5mbjYp/L4S1wOyoMu+By1m7cUnafWtU3Zsb+03VimWy5ok
         i4Lw==
X-Gm-Message-State: AJcUukd96oliLH2D6MeOSxPw6TTwms8qQULSphfd4ANhL6oWWpJu46T1
	WfBqqS0Phe3z00OKP8JCay7AeaOEkT3J77irJizsqXP7P5unN79hQjSGFhAFs3Ngf8q3zknozrL
	k5UKATdO+gUq3HhgMdzoT4mfkWJtixQ8pejAJaaNEHp1FmmAyI7y0jJOcyVGQVJ/lXw==
X-Received: by 2002:a17:902:4523:: with SMTP id m32mr27823540pld.53.1548803763000;
        Tue, 29 Jan 2019 15:16:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN74GE/ECs2+7KwqARDjoSJ0knrmPFd/H+M7PTRZSOhwh65auuT2kTZ4JkRW4QiTyW+fUhSG
X-Received: by 2002:a17:902:4523:: with SMTP id m32mr27823494pld.53.1548803762236;
        Tue, 29 Jan 2019 15:16:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548803762; cv=none;
        d=google.com; s=arc-20160816;
        b=rf2hNKUnWa4sB/m86IjBTFPSjPBIYXc0f35H2BeYVegqmGjtZR0BcUqzHirteJZp+L
         3/PaivZ+chi8nwo6KJGFV4suEbQ2PTox10/uYXYXgswfHihHIz5qjuN/cOz3Vi56rF56
         w4xkOcQclEcAgz1nULcEkB2bGZwh5H9JSFLDySUVA4IANejd5N2QA4APd3MfhV9Nu+Oj
         4AzX2TY5WqbzLeIrhwOBQoRTxrLzUBcMGOagdiIk2um8TXjTqPcWvPCY1cCcI0yPo7HO
         C3k0nUM4TTOn9HWmEQ2Y9JSD89Pk0zDKJ4sJdpFldsmyVb69qhl3VTlGrY9nOO5a2zkS
         vUDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:to:to:from:date:dkim-signature;
        bh=9u+YV5IcvYsQJ8cY1MX2zpgFq03ogjt0USJCUCHFOBI=;
        b=nB4AnzDwCkAsOjcrigDk+A6B9o6Z8V7JcFf2wwc3loY7Z7opDq8Qmos+U2+FUDkZSr
         2bpspRLUWoUkjaWNBYYzDGZLpWfUOBLIlZmjy1IdGRgLxb/gDJ+oWgP4/h8lEjC+KfWm
         L/rHsjPrWXmtnG/xfisaihBXQjHo7lvfYdPcep5TBNAYpGzwZKkseVb73dfx70eezMke
         ElcWdJAa7E/cYcyxIu+aXLgDSPe2bbyEDI4wurbByz/AnCZvICWKJ2aTMToem2ElFyRb
         DvGRj1D28whd91Gx++HNE3u92rKrpRIBHEFGYeSKhlkFjdb1uPFanl/uOjyU1h1+SHNe
         kylg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=g5iG952b;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b5si9017575plr.355.2019.01.29.15.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 15:16:02 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=g5iG952b;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A97972175B;
	Tue, 29 Jan 2019 23:16:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548803761;
	bh=RT5d2QR9t1oI07s93gTOqf0QDHmAo2ReSrHMvjAvtak=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:
	 Subject:In-Reply-To:References:From;
	b=g5iG952b5jOXdOMXy5D7MroUTGVTfgT4A8i9FF25FyUprDkIEcEjzyEfw+axlsXRI
	 fnNK2RpoOab2GXRO77UrKTglXKXu2koDv8mVmg4mK5hUsTvUHMglp6++e6o6bp7+o5
	 XLkDcSbCn13wGVotXdj+ek1Vyk071QoXJFvz4ML0=
Date: Tue, 29 Jan 2019 23:16:00 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   David Hildenbrand <david@redhat.com>
To:     linux-mm@kvack.org
Cc:     linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Vratislav Bendel <vbendel@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v1] mm: migrate: don't rely on PageMovable() of newpage after unlocking it
In-Reply-To: <20190128160403.16657-1-david@redhat.com>
References: <20190128160403.16657-1-david@redhat.com>
Message-Id: <20190129231601.A97972175B@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: d6d86c0a7f8d mm/balloon_compaction: redesign ballooned pages management.

The bot has tested the following trees: v4.20.5, v4.19.18, v4.14.96, v4.9.153, v4.4.172, v3.18.133.

v4.20.5: Build OK!
v4.19.18: Build OK!
v4.14.96: Build OK!
v4.9.153: Build OK!
v4.4.172: Failed to apply! Possible dependencies:
    1031bc589228 ("lib/vsprintf: add %*pg format specifier")
    14e0a214d62d ("tools, perf: make gfp_compact_table up to date")
    1f7866b4aebd ("mm, tracing: make show_gfp_flags() up to date")
    420adbe9fc1a ("mm, tracing: unify mm flags handling in tracepoints and printk")
    53f9263baba6 ("mm: rework mapcount accounting to enable 4k mapping of THPs")
    7cd12b4abfd2 ("mm, page_owner: track and print last migrate reason")
    7d2eba0557c1 ("mm: add tracepoint for scanning pages")
    c6c919eb90e0 ("mm: use put_page() to free page instead of putback_lru_page()")
    d435edca9288 ("mm, page_owner: copy page owner info during migration")
    d8c1bdeb5d6b ("page-flags: trivial cleanup for PageTrans* helpers")
    eca56ff906bd ("mm, shmem: add internal shmem resident memory accounting")
    edf14cdbf9a0 ("mm, printk: introduce new format string for flags")

v3.18.133: Failed to apply! Possible dependencies:
    2847cf95c68f ("mm/debug-pagealloc: cleanup page guard code")
    48c96a368579 ("mm/page_owner: keep track of page owners")
    7cd12b4abfd2 ("mm, page_owner: track and print last migrate reason")
    94f759d62b2c ("mm/page_owner.c: remove unnecessary stack_trace field")
    c6c919eb90e0 ("mm: use put_page() to free page instead of putback_lru_page()")
    d435edca9288 ("mm, page_owner: copy page owner info during migration")
    e2cfc91120fa ("mm/page_owner: set correct gfp_mask on page_owner")
    e30825f1869a ("mm/debug-pagealloc: prepare boottime configurable on/off")
    eefa864b701d ("mm/page_ext: resurrect struct page extending code for debugging")


How should we proceed with this patch?

--
Thanks,
Sasha

