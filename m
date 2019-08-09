Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B54A8C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 21:46:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59F14208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 21:46:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qVHDCIU/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59F14208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFB9C6B0003; Fri,  9 Aug 2019 17:46:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C87176B0006; Fri,  9 Aug 2019 17:46:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFFBA6B0007; Fri,  9 Aug 2019 17:46:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 748286B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 17:46:05 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n4so57640077plp.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 14:46:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mCwS7cxn6b0GybJWZcye9USSGQ9q7Fmyppw5ZMko8KU=;
        b=k6RthIeJQRPCsEYr2T+5Z/zpFU3avo1tCiiVpgYsF5/w2QJCLklEZeQVmZWDLycmdz
         a3gvKw6K3jnd4qw2jtOqrGenkzKxW9/Q4iHwZaFlHigxb8rCRK7s998zYhzkLfsIrJTW
         ZamDaQSEtUd2b7mu1kqJn2USSj3XNXdKQpLiSt/VjGvU+Qyl0Zlgi5gpJwp/Znid2v3r
         CaSn/s7/Qsqn5mBTkQl91vOagDNbZna+Spa/xbnZOCjZ0iWOBTi50Acr9Mn7vb+Ghtiy
         ui1lyXcrvAaHFvMWAFBRyMR5bcaf8qI1t2I2RwrM+bv1/5x++psTmmL9BntPyWDHKgt2
         DGTw==
X-Gm-Message-State: APjAAAVmHPLQDmBhvEwtpXDtBwJSup1ANXMIy9dulAlADveWz9PqNLQb
	fXZPXf63g05vAn2ejFJqmvr4oAgpy7o5NyGmtMOO1URI2X73VKaGPGMWU+PxvtlsN/N1mz1tbBu
	f4rHycYMuUjsZGR7KGPciOuBbF2oVLUnshYbOX0pm3oD2OOUk566VRltZMfo5vA2kKg==
X-Received: by 2002:a65:68d9:: with SMTP id k25mr19429333pgt.337.1565387164889;
        Fri, 09 Aug 2019 14:46:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytkg/aRSTPCyGa3wwyzArJ7UGwQd3DYqmileDKZcdrk9FaGu1kJbrpYyzLARk5i0Q06PYb
X-Received: by 2002:a65:68d9:: with SMTP id k25mr19429289pgt.337.1565387163966;
        Fri, 09 Aug 2019 14:46:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565387163; cv=none;
        d=google.com; s=arc-20160816;
        b=RILss1h2nOL0D08KX1kPV3jJRwzFEplEc0HmRkBfU6tO8mYlVI8C2XcAqiCFY29Nxg
         HZqNru+kMub4bpQcUPv0e9o7YWg8eHpOTyPdqC+oVyYxqtPnBXvEkYeOhCa7OLKFG+KD
         2vhj/smOEkHNIQlZMTvXdTtb6Jm1AllOnQb20xeWevWJsiKUlyIuJBCbON7KUegse6fD
         rJS7MuZykDNOsYjo5pvCT+1BFDMPdhNroesvX5WOazN0pnJCnoFAYSWbN6L3gIbykBiL
         UgQt6+ZPQN1X8g2lGUJ4rnZGJVoqfCyIZcd9zQjaE9kAS59WkziNV5N9UH9JNuzr1UNY
         XMCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mCwS7cxn6b0GybJWZcye9USSGQ9q7Fmyppw5ZMko8KU=;
        b=YcwPUiuNM3in0WCVZ53VVe+jo/to6fIgZ+pELp4P1aGiIoeXEYviNQU0tlv7YlWIdG
         zBi27KPcqm9moRJv/IyBN+qO3o4odC/Ju9pz2NUZaNgk7xtEFDwFJBlJPXbNCfa7CtY7
         KhmqrntdgJJNGWfdndFuSvzAx9S7V6OI4H46M8AIBbLof2HJ1L/TRVBQLTJsJuhrQOdS
         KkRSXObEG5jWfJyLZbOvh0u7ClHUs9etOc6+C8fa7S6H0hr/j+BxvIJJyPYfBZ+Dj/ph
         UpDvxMrftz8B4uGcNI89gVa9j2XVVNhF7uFGUk51GJJDvplVMqhxEIcDFi6wh8iHsSSF
         sZEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="qVHDCIU/";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o11si5417241pjb.30.2019.08.09.14.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 14:46:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="qVHDCIU/";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2B823208C4;
	Fri,  9 Aug 2019 21:46:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565387163;
	bh=krs14MxqF/pN/1zEXk5uy9zIQQ+Idv7oecPmObOlHuI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=qVHDCIU/kq/eMF+7450sA0Gi4W8R6Pt/6iQN+5P1onujMQsj2D+51QxXu1tMalHhz
	 CzSqV6LdCzbPLLgUOALzHnHzZ1E2TwbSx/8Zybo6Hg3MiCu1xEJUTwarfxo0DzpjZM
	 UNWKCraKny/ooTAo/Y+z9FA44E3OT/1oVt8C3kts=
Date: Fri, 9 Aug 2019 14:46:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arun KS
 <arunks@codeaurora.org>, Oscar Salvador <osalvador@suse.de>, Michal Hocko
 <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Dan Williams
 <dan.j.williams@intel.com>, Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH v1 2/4] mm/memory_hotplug: Handle unaligned start and
 nr_pages in online_pages_blocks()
Message-Id: <20190809144602.eddc3827a373f17ddda7d069@linux-foundation.org>
In-Reply-To: <20190809125701.3316-3-david@redhat.com>
References: <20190809125701.3316-1-david@redhat.com>
	<20190809125701.3316-3-david@redhat.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  9 Aug 2019 14:56:59 +0200 David Hildenbrand <david@redhat.com> wrote:

> Take care of nr_pages not being a power of two and start not being
> properly aligned. Essentially, what walk_system_ram_range() could provide
> to us. get_order() will round-up in case it's not a power of two.
> 
> This should only apply to memory blocks that contain strange memory
> resources (especially with holes), not to ordinary DIMMs.

I'm assuming this doesn't fix any known runtime problem and that a
-stable backport isn't needed.

> Fixes: a9cd410a3d29 ("mm/page_alloc.c: memory hotplug: free pages as higher order")

To that end, I replaced this with my new "Fixes-no-stable" in order to
discourage -stable maintainers from overriding our decision.

> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

