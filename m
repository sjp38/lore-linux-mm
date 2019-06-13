Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9B43C31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:18:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68BF02173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:18:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="B6QwZ4EL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68BF02173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 017BC6B000E; Wed, 12 Jun 2019 21:18:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE40E6B0010; Wed, 12 Jun 2019 21:18:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D842A6B0266; Wed, 12 Jun 2019 21:18:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF1E6B000E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:18:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v62so12629511pgb.0
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:18:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bxihxNNysPXerPyob9Zzk921oVuc/OIiBaUeQPYANHw=;
        b=kh6qsKCHmCssNdbXl+zxuAaq31vVt002GwBIX9q8lh4XHkx2pcMiBeGZzAxMiah6lp
         +eshH+mpD86c2nI82KEp/+sSwiE2Q2kEyvSSpFrFVWBhbfGgYmEeu4W9Bzn+hLFt4zn4
         JQp9TNVwq5ZbADQV4ybD+Q/jEXGlASO3BnnospZoXr/EfthdeMSz2uu3Y46V4C+jofSw
         LyUB/Sr5LwbitGcoW0yhq+VmBF0ygTR9m+fDBZEdTYzQxjweOt/bEo7NmXpvyFCPy/0t
         cjbgJtIdt65Nuet2zogF2a1KKi4PKNB83s5SqdwgLmf5QBzGmKb2EWtJgOopuWf2SDyw
         /6tA==
X-Gm-Message-State: APjAAAXL0ClBNLHhqrgUcMehA0eS1LTh1+0TIVuba9nl+dF5vCjacoww
	udohQRoOz0bkMz1d1QbR7zCJpEd7iNCE2anUxlie8rJTO+gvLAhtdzb33cqk9yIEIrJM6iG2ytl
	uXFvW5LZPKt7gOpO1A6KptVD+RE5zc4i7jQl1v2pfLorCasTmqIXawcRkvmkmxCMBcg==
X-Received: by 2002:a17:902:467:: with SMTP id 94mr28770477ple.131.1560388695320;
        Wed, 12 Jun 2019 18:18:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2Er4xuLqB/HgMWrKt6YgRIPm+dNxH89cvry2cCWiIsYD5uyPnGFhJhfZHYKzJF09xAexv
X-Received: by 2002:a17:902:467:: with SMTP id 94mr28770437ple.131.1560388694580;
        Wed, 12 Jun 2019 18:18:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560388694; cv=none;
        d=google.com; s=arc-20160816;
        b=utScaRwrrl7QmhlEQLF9OFMObKH43KsqS0ViUgwq/M+kE/XWyFbob+8DkF0R9CaG+S
         1r2Ko8mr7BT5anRfxvZHRV7echAnG4yJzsrQ7wwlBoN7AzE9NbgSidFv8hJXenTUt/go
         miGNT82on8DrsHkzWXl0cCZbvw504Vmdod5zfRoUdfGvRnZXzSZxouUMpGpUkGi7I8xv
         odirgOax9Si5gZadGiFd5Kr3Zae3cMe45N78S3pye+eiYitWbMCcFTZgwusqabi0nM7o
         z9+hR0tX7LAZBs196j3oMMLQ9GbfxYe6z4Fb0WUsJFX3GLkk2uTUFqlWGvxBb6g8tc+v
         RBHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bxihxNNysPXerPyob9Zzk921oVuc/OIiBaUeQPYANHw=;
        b=RPkIJASdXV5shAkfUXBpryo9O5VfktfDSr/5n5A0mQ9ol/ZtS3GetGPeJii4UMncLz
         p0JqM6Gca7pxERC9KeUlWRyJRFD5egtB8a+aFuLaSWvPH3Q3JtF46hoCaUtiXc7C0VtF
         rEI2F6UYr6r2pcD3v/dETquyNi8GlaDSGrP4uQ1ss/OD6SQq0g9VkWJ4YBhj4FGnW75h
         uvf7gA3kMDpsrbhlcBXqhhXl4uDSWlAUjpOxGvoGQ1wMFvqqZlZXaWltfaVLIma+WkSB
         wtVAF+8Yq9lB+xrzr63qwqMgqRtL/4ygaaNLyE5GS07gX0dFDSfoBNDVAUZ1tlpd8aJ4
         0esw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=B6QwZ4EL;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h63si1256380pge.558.2019.06.12.18.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 18:18:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=B6QwZ4EL;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9CE68208CA;
	Thu, 13 Jun 2019 01:18:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560388694;
	bh=t8ziDUjGRatmX8RI2sR6uyYMindRv5VWtp1mspyO4HE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=B6QwZ4EL/RBtMxQBQ2C4dYwyr9DAJ+Z2Z3aJYcMQaieNiGU59KS/u8/xtLLpUbW7T
	 m8OVV9+d3Wy/w/AD79mktyWQ9phS4xvdMROxkLy5tWqzeIv5KZdGBnmd8Y37PQfYMW
	 8g+LcA6tVIJiZ3F672gNG+5F6YHn3ViB+XbeCa+A=
Date: Wed, 12 Jun 2019 18:18:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org, ocfs2-devel@oss.oracle.com, Mark Fasheh
 <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>, Joseph Qi
 <joseph.qi@linux.alibaba.com>
Subject: Re: mmotm 2019-06-11-16-59 uploaded (ocfs2)
Message-Id: <20190612181813.48ad05832e05f767e7116d7b@linux-foundation.org>
In-Reply-To: <492b4bcc-4760-7cbb-7083-9f22e7ab4b82@infradead.org>
References: <20190611235956.4FZF6%akpm@linux-foundation.org>
	<492b4bcc-4760-7cbb-7083-9f22e7ab4b82@infradead.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jun 2019 07:15:30 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:

> On 6/11/19 4:59 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2019-06-11-16-59 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> 
> 
> on i386:
> 
> ld: fs/ocfs2/dlmglue.o: in function `ocfs2_dlm_seq_show':
> dlmglue.c:(.text+0x46e4): undefined reference to `__udivdi3'

Thanks.  This, I guess:

--- a/fs/ocfs2/dlmglue.c~ocfs2-add-locking-filter-debugfs-file-fix
+++ a/fs/ocfs2/dlmglue.c
@@ -3115,7 +3115,7 @@ static int ocfs2_dlm_seq_show(struct seq
 		 * otherwise, only dump the last N seconds active lock
 		 * resources.
 		 */
-		if ((now - last) / 1000000 > dlm_debug->d_filter_secs)
+		if (div_u64(now - last, 1000000) > dlm_debug->d_filter_secs)
 			return 0;
 	}
 #endif

review and test, please?

