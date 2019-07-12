Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43B2DC742A4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 00:04:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE9CB21019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 00:04:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0e1mYioN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE9CB21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64B198E0108; Thu, 11 Jul 2019 20:04:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FAB58E00DB; Thu, 11 Jul 2019 20:04:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EA508E0108; Thu, 11 Jul 2019 20:04:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16D838E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 20:04:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w5so4571829pgs.5
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 17:04:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=naI9uwbkGzl63SAhrwbp4k1vFO8/zJ1WHN/+zImeOJ4=;
        b=E2nDfBsTqiGLR5Qh6464FnRluNg/SES0et4/qUtpj6ov7WGlt6s1UksjEtZjht/tbQ
         4UG39oZDqZZjzKBDehmfYcJInpbcldJdfp+9VzZ+ydMyYruaCA1NHvFbYoHurVbdlyZH
         gk875ig8WdDz8cH05pI6cWWgb9IOcnFG1DU43NACvcdcVgIUjEnp3ryH20GPgUHFhHGs
         X2BAkelNSVnSX08myZ1Mwz24pxrppOtGXuTGswlH055zBRr4NWgQOxKIBucMc0GOv5kL
         NTqCZDZaxtquqFA5//DkCpr0n0ZszmS0zkdPh/k+E4Ugqu0aqugy66e4ajdyaCt4SM1O
         y7TQ==
X-Gm-Message-State: APjAAAUIs2WXWCi4Fgj9bbFgHmIvVUYScPPNCrw5WWOZDzwxtXMZ/CJB
	W4mb0J50qFBfWpUMorIh5+h1O2IZZpV/P9ZdBdxTxmN5YqM8pCHLfOCO0BDwVsVj1psZoTUHvHX
	WLYHTZI7u9FzxihxCfTrantF6pbXuwEveGmpgWCwxL66ibNT9oaib5OqGHQGRR9suyA==
X-Received: by 2002:a17:902:b43:: with SMTP id 61mr7891641plq.322.1562889897710;
        Thu, 11 Jul 2019 17:04:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWDAQNPumSQaE40dR2N9/n/XBlfpUkyJxDs4cncN7IXrFAi7S63RBUb5ghk5nInY7fVFPR
X-Received: by 2002:a17:902:b43:: with SMTP id 61mr7891578plq.322.1562889896977;
        Thu, 11 Jul 2019 17:04:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562889896; cv=none;
        d=google.com; s=arc-20160816;
        b=QgHwmCg/vrFGpcHjscHRyL0iTkp+FQ3Wf7XNxYoJO97j8VQqarwGQMqZBuTWqX94ak
         QKK+5bZ60B69XDAbyPiUcoj3PEOTVWUhh2AeDRpHbAzw2NT6LRcFEu4TdlpbuJamm54T
         gCjC+b3lXKQVuOTDihWr0WgfpMjITn5E4kOUn2iPcLe7OE9hS3AZudnZcmeH6efpoyfr
         Ws827C2tPxx5ybKpd64y7zCO9BH1MM6Yrv8R75KjcIbTtgLf8SYj5dMSj7dff75hJDGa
         /3kBNt7Ob/pvT/Av72ozwqTJM3J4kO9FjLcUhVpz4cTnAwCu3mP3e9pVuoPGsIZHYlXK
         AMog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=naI9uwbkGzl63SAhrwbp4k1vFO8/zJ1WHN/+zImeOJ4=;
        b=RfEYtJcMj1RyjfQVMppm9QLg2bQdMeToGJtsyAgoeg7xyIJDCdA1jUnDgW+vqloRwb
         KgCjxKvX3w7QxXtpPqZypWba2LPxxZbbf0l88syY6jBM/RZDsp6lvPMWkhhviAkWIpl/
         T7Hp92db+i1zCcIXcibuwUpopWxk4WBKaI/2J0zArBTF6sOf4AFRCX3nx5TJyffJIYP5
         ee2wQgZB5YeRfCF1dmZc7S0wqRVoIeoTvYjS0NOeL7ahni0G/CyvEv3SMZLZsumh/uv9
         WPvYui5O7J2auZ1rNcr246oveMxR6g9/qrHGlfS8clkSBWjnUK4IVt+By3x6hxhVrpD3
         I8eA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0e1mYioN;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d31si6175992pla.84.2019.07.11.17.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 17:04:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0e1mYioN;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5782221019;
	Fri, 12 Jul 2019 00:04:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562889896;
	bh=RUU96y3CL94NXnq05VuKbhkW/5unmwebIUCOiqzgxbQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=0e1mYioNDELxTwqtfNeRxo4F/NiP6+z1joxUw2rSKLIqaxwRW7LGFZ25qSs7yBtCT
	 JocX2GL9SkEb944Md8/x8Nuzyuq+CaS5jwPvuTNjuWOv2Lqt+hzZ2305ibIarJCj9h
	 OVu7ifwlkMq23nofZGVRpJCrYE4xnTBZZvJUfFKI=
Date: Thu, 11 Jul 2019 17:04:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jan Kara <jack@suse.cz>
Cc: <linux-mm@kvack.org>, mgorman@suse.de, mhocko@suse.cz,
 stable@vger.kernel.org
Subject: Re: [PATCH RFC] mm: migrate: Fix races of __find_get_block() and
 page migration
Message-Id: <20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
In-Reply-To: <20190711125838.32565-1-jack@suse.cz>
References: <20190711125838.32565-1-jack@suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2019 14:58:38 +0200 Jan Kara <jack@suse.cz> wrote:

> buffer_migrate_page_norefs() can race with bh users in a following way:
> 
> CPU1					CPU2
> buffer_migrate_page_norefs()
>   buffer_migrate_lock_buffers()
>   checks bh refs
>   spin_unlock(&mapping->private_lock)
> 					__find_get_block()
> 					  spin_lock(&mapping->private_lock)
> 					  grab bh ref
> 					  spin_unlock(&mapping->private_lock)
>   move page				  do bh work
> 
> This can result in various issues like lost updates to buffers (i.e.
> metadata corruption) or use after free issues for the old page.
> 
> Closing this race window is relatively difficult. We could hold
> mapping->private_lock in buffer_migrate_page_norefs() until we are
> finished with migrating the page but the lock hold times would be rather
> big. So let's revert to a more careful variant of page migration requiring
> eviction of buffers on migrated page. This is effectively
> fallback_migrate_page() that additionally invalidates bh LRUs in case
> try_to_free_buffers() failed.

Is this premature optimization?  Holding ->private_lock while messing
with the buffers would be the standard way of addressing this.  The
longer hold times *might* be an issue, but we don't know this, do we? 
If there are indeed such problems then they could be improved by, say,
doing more of the newpage preparation prior to taking ->private_lock.

