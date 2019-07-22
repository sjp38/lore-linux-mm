Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81EA9C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:26:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46D58219BE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:26:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ogi3k+rE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46D58219BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5BAE6B0003; Mon, 22 Jul 2019 18:26:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0CB06B0005; Mon, 22 Jul 2019 18:26:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD4FA8E0001; Mon, 22 Jul 2019 18:26:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77CA06B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 18:26:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4so20197084plp.4
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:26:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=u2fOlu0SFGmevCQwPRz9BZtZC9QuIoaJMg2cdMM6wGU=;
        b=QblF1BU45cmmLroWinhJ7nI3w5WPTxb/OSg/DhJU0LCIJIK6iKv8Emh3wLyt1JA2CO
         5WUd466Ml07sViLbIE5ceipbQEey9ZPLIoodFxa+dmm3Q9x4hTsvvesJYC3/XJm7+2iq
         Jesk0kDLxdlsCqqxvPQUAkF5lL4zomG3NrVWI9b+bbfh63X2kC9A4aM+9hWf5thU1DRw
         Av/kbArY3GJXOowpLR0dRY3hBShIWzaPuNTfF+D1nYbWcmxeXr/gYSTwu+cROptl6qk+
         E3ySnikiuqn7bKKHvfSfL2PqugfIAM4KVJ3e3zPQasmA4RQhKnkFkQPxCI4/7IuVhWBK
         Z8kQ==
X-Gm-Message-State: APjAAAXhW6GsNq1Ch/MIfOC6YCoLd4JGiiHt86k32erDpD8HvpzxnU//
	O69SXKzJqOzid72jhUyWLWwMB1M/ntXDdceF4+zdRlCSYE9k2VhLUcMzheQvn7+vb5JJ+iPHUG0
	Gcw7zo/wyG2D7EyBop3B153mKJRx7gO+GOOntMNpQoYB/Q1x8Kk3w+DlttmzRYW959w==
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr71646142pls.120.1563834370032;
        Mon, 22 Jul 2019 15:26:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzexXRBctPO8Y59T6nuKa+o+I522713NU9QQ5gYvoCcVU3cB1vYysJ75dQL1JxmXGw/+atT
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr71646085pls.120.1563834369049;
        Mon, 22 Jul 2019 15:26:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563834369; cv=none;
        d=google.com; s=arc-20160816;
        b=qUIQ+TYnwnzbGfWBrguLq5egAMEE0lgZGWbQ0O+PJDGZ91GvW7xwLFWgDSgPOnA0t5
         pD/gE5m9KJ7vByl9CkEdhGF0kcjTYHWvEIah+H/RH/6X96wyUQb3jb7KIZEwUHY8ubZk
         4cLh9PiTkbEhx2+RmSjSDqNjTojUnHOn7iXSUamLu5fwxp9R+K/o6jxHqTfO35DxDSqS
         Csok9fZCTrLhU4xZeZqmFIPdSzDshYHXJLILZGxJcw1+mFsJRM2nhXnuiqUNggWARQof
         +bRpOWV5xXPFEy/TMIRsfge9w3NkLOmTqr5mQfCUoBlazbwCwkp9xwZ7P/Lu/wtelUqw
         QdDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=u2fOlu0SFGmevCQwPRz9BZtZC9QuIoaJMg2cdMM6wGU=;
        b=IxdGJbJED8qffYoyqgncAmqjw1kT6RGr99nPEIUN3UknvIwlUcXY/ItdXyxzBVzGgT
         S2JxpnKfHIi/cDk4vnLtiXMABCFf/fTx4mUpNA4CRE7lhe0EiDvzKTE4ephYcvcuj5jY
         qNGGaviBTRaN+4zA3N3PNnW0DIptEj8aCsCPpd4+B0wUhhyjyjtQ1EN3km7ZUtK32Sn+
         Jka7C5RJJ7GRQW3Yi33FI2ZLWIuQmWO9XvEdRpXmmZzNdoFNoo3PBWzdHaosL3MmJRiW
         pIw9oq1T74ElmQL6xzaNG0NgWuJ7wj+2+wg+4nV9dvHOlO0H7oof6VBcpTJVhF6Hjf5G
         cTXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ogi3k+rE;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e2si9636351pgf.256.2019.07.22.15.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 15:26:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ogi3k+rE;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 484D921985;
	Mon, 22 Jul 2019 22:26:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563834368;
	bh=SaCZr/lqE3KBkwJxJ3lN9pVqMFlNvyqSapA1Iar2Yz4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Ogi3k+rE6tk0IM0RMI1sxYzidV8NLfAQfkbaqZqpx47sIH3rytjrFbF0L2h9+viUc
	 HXSYDvdHUkfN2kpbEa5fKWrQdie7drx8APmpPamwnuov0yvOqo0lk8hQ21R7nNODV1
	 D/z8/0j2BEGTqS2l1Mi4j87EjG/KCZECdTJfkpyY=
Date: Mon, 22 Jul 2019 15:26:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
 linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] psi: annotate refault stalls from IO submission
Message-Id: <20190722152607.dd175a9d517a5f6af06a8bdc@linux-foundation.org>
In-Reply-To: <20190722201337.19180-1-hannes@cmpxchg.org>
References: <20190722201337.19180-1-hannes@cmpxchg.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jul 2019 16:13:37 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> psi tracks the time tasks wait for refaulting pages to become
> uptodate, but it does not track the time spent submitting the IO. The
> submission part can be significant if backing storage is contended or
> when cgroup throttling (io.latency) is in effect - a lot of time is
> spent in submit_bio(). In that case, we underreport memory pressure.

It's a somewhat broad patch.  How significant is this problem in the
real world?  Can we be confident that the end-user benefit is worth the
code changes?

> Annotate the submit_bio() paths (or the indirection through readpage)
> for refaults and swapin to get proper psi coverage of delays there.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  fs/btrfs/extent_io.c | 14 ++++++++++++--
>  fs/ext4/readpage.c   |  9 +++++++++
>  fs/f2fs/data.c       |  8 ++++++++
>  fs/mpage.c           |  9 +++++++++
>  mm/filemap.c         | 20 ++++++++++++++++++++
>  mm/page_io.c         | 11 ++++++++---
>  mm/readahead.c       | 24 +++++++++++++++++++++++-

We touch three filesystems.  Why these three?  Are all other
filesystems OK or will they need work as well?

> ...
>
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
>
> ...
>
> @@ -2753,11 +2763,14 @@ static struct page *do_read_cache_page(struct address_space *mapping,
>  				void *data,
>  				gfp_t gfp)
>  {
> +	bool refault = false;
>  	struct page *page;
>  	int err;
>  repeat:
>  	page = find_get_page(mapping, index);
>  	if (!page) {
> +		unsigned long pflags;
> +

That was a bit odd.  This?

--- a/mm/filemap.c~psi-annotate-refault-stalls-from-io-submission-fix
+++ a/mm/filemap.c
@@ -2815,12 +2815,12 @@ static struct page *do_read_cache_page(s
 				void *data,
 				gfp_t gfp)
 {
-	bool refault = false;
 	struct page *page;
 	int err;
 repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
+		bool refault = false;
 		unsigned long pflags;
 
 		page = __page_cache_alloc(gfp);
_

