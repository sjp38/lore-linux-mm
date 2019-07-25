Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ECFDC76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:36:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAF9E22387
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:36:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="i0fC83yp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAF9E22387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 491468E0025; Wed, 24 Jul 2019 22:36:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 441B08E001C; Wed, 24 Jul 2019 22:36:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3577C8E0025; Wed, 24 Jul 2019 22:36:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 014F08E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:36:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r142so29833901pfc.2
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:36:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CB5Z8nr1WZSSNnI22cPzZ5y4y81aFkRUJTfJZecdvYA=;
        b=A7IJV/iJu1JzeddYvxEOTHGGQsfVFfg8BjJLxS4SbFfhZ43cEi3iMPh9jW1EfnqS7G
         CFI2CdrAC7ExMYzbQASfxuFyX77V6Rv0ZZdRkknsB1CqyQtk47Pi6M7wWFbM+fhRfGMe
         qY5ySvewZNpHF/83Jl7na2uhOXDF2b2s0rLmHT3NnITIi+YW0gDgoG1WBFaa/KdA2+A1
         oEqPgzWoaYONHBxH0GuLyEo9RyUEJIHD6SlRtvVK2uNeymPYI85r5uotmWhD0xrRrtdd
         ET05qW8bRcFhcSzdJq3uobsFN6DHulUU3gt7L01hI9/3HAqhQnXVmgi+tbGLkWL9IVkc
         oJvA==
X-Gm-Message-State: APjAAAWIHlszuyGfd+reG8LU4b76S4HrVdApI7E5V9qofUEnU0UF7XFL
	AxLZzdfF3C8DYiKY4MoI+Jzw3wxNNMjMHqq3Jrc7nS3oFVyDuX6L83EcoOPR57CUpkUpfzfF1FJ
	m7XBhUaacymFwpIea0T0iuz8pnw7m9fmEbAqXRcax2Vyics7bTJhHqaLYLkUTJKIsVQ==
X-Received: by 2002:a17:90a:208d:: with SMTP id f13mr87732589pjg.68.1564022199668;
        Wed, 24 Jul 2019 19:36:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKGtBZQ441ylvTNV/WoD8xBXumgS/4EMCIyfTvSWzPXiQFYSu0gr6hRBE5246LOQbuS7nB
X-Received: by 2002:a17:90a:208d:: with SMTP id f13mr87732551pjg.68.1564022198940;
        Wed, 24 Jul 2019 19:36:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564022198; cv=none;
        d=google.com; s=arc-20160816;
        b=pYNV9MUBylvO9HIWRr+GC5kchMjb3Z2dABBV2j+0zW4cqgg4j9k+uNAYEvOi4hqhL3
         jw0fAEHDx+CAfLkeFGA0UGEaViL8bcI/m0PoTIlIbKOFatG2NV2BC8FVVWQ9SDCWtf/T
         c/eQOZOnLGcI4b2wkuhk91WdJ2kcGvn84JGBO2KSujvVzB6MAGoARdvnJ+92jzuc3Cvv
         FFQ/pF8cwT+qDXcGCre8wLY4dXrKlFhJAoa9lEC5ytPNfh70SaJBDW/5HvzbVPAno8EK
         nEgQxBZEdlDm1se4P2S7EvEOOTBgucoLwtkKZnyy5t7yw1uF3BQW88Nlc9TTY9NnQeek
         EA8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CB5Z8nr1WZSSNnI22cPzZ5y4y81aFkRUJTfJZecdvYA=;
        b=Zp3BG7ZMuDRwCsHzBoAOMFFzraOSUZE4Ow0qo70k7vOadfHnooXkV3nsT8xBgei0mc
         HAETigZFT/5eP6/w+myZ0i3fCAiKUU2P9KjXUYv6J5U+W901mgkWjvJEGgcSBKOEpRVh
         VMKiIUfivDyHbEb6ScxDo3YYpQodTfNJrFZmC7dBuCKJ3pE/X8u2UsCmeS7uQMmpHPz9
         UkpfSrCGECP6EN9fQGpADN9F9JQV4P5enCGevZNh6CGuNsSvMKsznmpAXy+cBmHAFAIb
         G1eZtij+5GIyT+Qi80057tsHdTEC5wGsQwclbap2iwFU9+XbrEeQ2oHdAr9UcA2PO7kV
         Dr1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=i0fC83yp;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q10si2934308pff.223.2019.07.24.19.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 19:36:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=i0fC83yp;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0EA0B21852;
	Thu, 25 Jul 2019 02:36:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564022198;
	bh=D1/XAZeml+GaFLf+eOsik3qb0TT1TCoXAkWbdZi4Uk0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=i0fC83ypNVUKB9EVai4LXo+v9ARw5Eyade7UDcE4YL+6sCTYavtEvzFa0Tykazaz+
	 SsLvMemZaTAs++xQk83lBYn2Grm5YGG3xvnbO7/nLnU1R+78CB5s67GOwvl1L5kqIO
	 uj/fRVIsKke3L1aYxS/VQVMNN28hRjeKuFm2wTWM=
Date: Wed, 24 Jul 2019 19:36:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Pengfei Li <lpf.vector@gmail.com>
Cc: willy@infradead.org, urezki@gmail.com, rpenyaev@suse.de,
 peterz@infradead.org, guro@fb.com, rick.p.edgecombe@intel.com,
 rppt@linux.ibm.com, aryabinin@virtuozzo.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH v6 1/2] mm/vmalloc: do not keep unpurged areas in the
 busy tree
Message-Id: <20190724193637.44ced3b82dd76649df28ecf5@linux-foundation.org>
In-Reply-To: <20190716152656.12255-2-lpf.vector@gmail.com>
References: <20190716152656.12255-1-lpf.vector@gmail.com>
	<20190716152656.12255-2-lpf.vector@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jul 2019 23:26:55 +0800 Pengfei Li <lpf.vector@gmail.com> wrote:

> From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
> 
> The busy tree can be quite big, even though the area is freed
> or unmapped it still stays there until "purge" logic removes
> it.
> 
> 1) Optimize and reduce the size of "busy" tree by removing a
> node from it right away as soon as user triggers free paths.
> It is possible to do so, because the allocation is done using
> another augmented tree.
> 
> The vmalloc test driver shows the difference, for example the
> "fix_size_alloc_test" is ~11% better comparing with default
> configuration:
> 
> sudo ./test_vmalloc.sh performance
> 
> <default>
> Summary: fix_size_alloc_test loops: 1000000 avg: 993985 usec
> Summary: full_fit_alloc_test loops: 1000000 avg: 973554 usec
> Summary: long_busy_list_alloc_test loops: 1000000 avg: 12617652 usec
> <default>
> 
> <this patch>
> Summary: fix_size_alloc_test loops: 1000000 avg: 882263 usec
> Summary: full_fit_alloc_test loops: 1000000 avg: 973407 usec
> Summary: long_busy_list_alloc_test loops: 1000000 avg: 12593929 usec
> <this patch>
> 
> 2) Since the busy tree now contains allocated areas only and does
> not interfere with lazily free nodes, introduce the new function
> show_purge_info() that dumps "unpurged" areas that is propagated
> through "/proc/vmallocinfo".
> 
> 3) Eliminate VM_LAZY_FREE flag.
> 
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>

This should have included your signed-off-by, since you were on the
patch delivery path.  (Documentation/process/submitting-patches.rst,
section 11).

Please send along your signed-off-by?

