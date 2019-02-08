Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC479C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AB2B2147C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:49:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AB2B2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B1D58E007B; Fri,  8 Feb 2019 00:49:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25F4F8E0079; Fri,  8 Feb 2019 00:49:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 103A58E007B; Fri,  8 Feb 2019 00:49:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF8268E0079
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 00:49:21 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id y2so1682829plr.8
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 21:49:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ks/eFtZMf2z0pCGMP0uadMDNQm+vNSqdslkJnl/9wRk=;
        b=IR9jLjgXE8SWHuPqzKJKOiQg/IzSANImEjMQqXqKSTvipdGmK77BI+94h9ZzwAFQJ5
         OKJq3cMn0QSiLwL/mCzxXfY6MQlm6f/Pc/q7OSHQcWOFGXQ2NBNgeY1/WK0YEp+LRRw5
         HYr5jkx1nS3rIR2YVU8rBZn31Ef6q/OT96+MGohfoDCmrP9Ic1ddAOnq4Zb/apfvWiU2
         HHrXl4YRgSuQf6D40L+OAM7oF+pK9p41Y+2lzuqD9zbBV4ybw1Fw8ou6M12G1vfX3uXw
         nw6LN2GSdYjYjY3wlNrWGnUJbTmbJXm9D1RHWPoJ2Iwd2MMITI7YPQtIYrYm2MpLqrWx
         amgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZn2jtwgS6Bbjdfu1q0g0QhFxRYGPuiPeWdmyQznPgJT8GaVQCj
	SqvGoS5U/mB1z1bQyCQD3H+aBf4zKj0m3AlHW8sT/npwYrDBA3bR/tiusJCDcqu+5Wh9lm2NL0O
	QWWW6EzcJWRCnY3dhbWCs5hDfGnG6hM/bz5Y3jA0Il4GAeM8m7Z7YFMFtW6qv8Vx+PQ==
X-Received: by 2002:a17:902:6686:: with SMTP id e6mr2024135plk.208.1549604961363;
        Thu, 07 Feb 2019 21:49:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1jPYvZ6r4+Y/da6aWgJ8n4VP9x2BUncenhe6Jywsxl69cD+7R5+/kkKpbQPAJRyBIXo2H
X-Received: by 2002:a17:902:6686:: with SMTP id e6mr2024100plk.208.1549604960702;
        Thu, 07 Feb 2019 21:49:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549604960; cv=none;
        d=google.com; s=arc-20160816;
        b=nKB2NLhQltHvHh+aYf/nAQIFROaadiOkyV82JVRaiPDJy/n4UNSwsMHR4pY6p/tyeE
         qVEZXa9bGsZ2hCSU0HhPfqD+aUkqna2TqIqYziU76M45W3ORsAQofy1PASYB61zknF8O
         GD03MmLmCtBMxJ+Nfi+QA6xXAScFrknbJ7oD++ffdhbmGKRo6efuPd9iM26IZ9eLwkCq
         o39XyYbFvJnjQwSBrvVOiH471bcqPvwWcV1IHbkzeFApFk6mr8YqTSwL4dP76zQowwpO
         QysSLzZxLclth2PPHj9P1jF53rElqQhprSjWxhAcwa3uS8p5BCN7SqpxZFel3sR2W/v8
         V/CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=ks/eFtZMf2z0pCGMP0uadMDNQm+vNSqdslkJnl/9wRk=;
        b=k9LFOEeYXTVrJ4t2i8OJyPz08QPKbX0zvSR7EjLOMsjYxNwwnCiQdLQlTxkIKQEYvd
         zjt9JHpxYJ6ffI/bvZ/0VQlVKFgYy4WOf/hzRGQCTGbycRNXuoyix0Oon742xyeR/ORa
         zAYJtRstYyQ4F7l3+7cVlzedAbktKNqWCG0zk1Or5lEZmpIqiuuOKNJhfTcEgc0+gdt0
         UD9MVm5nWTOWemyHydxBqF7ZT7QtN6ZgXMhudRvjA2/5Wsl+C59BLvyRc8dV/k1HOoSf
         /duVM6v3eimag6JTnMhVfvi0/ZFq9P+MrqC8nS2bqP6oSx6x6UsJ3832Jkw2D9b0k60Y
         Y8XA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p3si1363329plb.101.2019.02.07.21.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 21:49:20 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id E469FBF56;
	Fri,  8 Feb 2019 05:49:18 +0000 (UTC)
Date: Thu, 7 Feb 2019 21:49:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: john.hubbard@gmail.com
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Dave Kleikamp
 <shaggy@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Jeff Layton
 <jlayton@kernel.org>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka
 <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, John Hubbard
 <jhubbard@nvidia.com>
Subject: Re: [PATCH 1/1] mm: page_cache_add_speculative(): refactor out some
 code duplication
Message-Id: <20190207214917.9d07ca3fc52d3df0cde018bd@linux-foundation.org>
In-Reply-To: <20190206231016.22734-2-jhubbard@nvidia.com>
References: <20190206231016.22734-1-jhubbard@nvidia.com>
	<20190206231016.22734-2-jhubbard@nvidia.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  6 Feb 2019 15:10:16 -0800 john.hubbard@gmail.com wrote:

> From: John Hubbard <jhubbard@nvidia.com>
> 
> This combines the common elements of these routines:
> 
>     page_cache_get_speculative()
>     page_cache_add_speculative()
> 
> This was anticipated by the original author, as shown by the comment
> in commit ce0ad7f095258 ("powerpc/mm: Lockless get_user_pages_fast()
> for 64-bit (v3)"):
> 
>     "Same as above, but add instead of inc (could just be merged)"
> 
> There is no intention to introduce any behavioral change, but there is a
> small risk of that, due to slightly differing ways of expressing the
> TINY_RCU and related configurations.
> 
> This also removes the VM_BUG_ON(in_interrupt()) that was in
> page_cache_add_speculative(), but not in page_cache_get_speculative(). This
> provides slightly less detection of such bugs, but it given that it was
> only there on the "add" path anyway, we can likely do without it just fine.

It removes the 
VM_BUG_ON_PAGE(PageCompound(page) && page != compound_head(page), page);
also.

We'll live ;)


