Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 981CDC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:02:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B37220883
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:02:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AUfFmnK9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B37220883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3A896B0272; Tue, 28 May 2019 04:02:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEBE36B0273; Tue, 28 May 2019 04:02:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB4826B0275; Tue, 28 May 2019 04:02:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id B183D6B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 04:02:00 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id z66so1598435itc.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 01:02:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5Anq1qwGKoGsIX6kb9ZWLK4o9JgSaVCCm8wVkC+oVCE=;
        b=sZAL/RFwPvOAaVw1Q+8FUSm4LH16JvjeY3dN4flOMNoK8KiIvCCnKLdZjqZ/X3W1Lf
         PnEkorQqs2ZiSa/yiOpO5YscuYdT6LxdeM32b41ifD/wLFoO+QGq1WYeF0NgGK9qZtOJ
         lPgpnjSXr7UED+L8mdG/x2oOVW7Ioh3JvLjy0yvPCbrpovdxLbXP/7wokNrE0GkkWFSG
         4chlmSl9s0xnjHwaVOBMatn+RDxfU6WviZ7Cwn0YHrJY/lkFjm0u9aTsTYtRXfbGQCLi
         3nDCdIzAoN1QrKeL6WwwMILGXWnhnyN24evvRoFgoK0fEwh0QfbQOt8HlyEzt4wtYM9b
         as2Q==
X-Gm-Message-State: APjAAAWWK4gl40N4vbI5aDqqYUG8oAbvKs2aHvT0Td7pc/s0eR3Fo1Th
	j/jTcbi/D//WsWGWUJBbM4U9Kh9z3cr3D8iE8C2SQhNXmQbYNnjcX4c6wqZRRZCSc6qxGTY7rRJ
	CAj2K21tAtHZUEOqy6OoiBrb/zFYlsSvB6y7ogR03n3pLti9dCSzQPaPAOmsnvOJ60w==
X-Received: by 2002:a02:90cd:: with SMTP id c13mr13003157jag.85.1559030520496;
        Tue, 28 May 2019 01:02:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQ8i6BzX4kcADSRrLGn0GN659jMXOKYdLSmiYoD60L/d9gMFNBz/q6a9t6653JO0za6pQV
X-Received: by 2002:a02:90cd:: with SMTP id c13mr13003117jag.85.1559030519914;
        Tue, 28 May 2019 01:01:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559030519; cv=none;
        d=google.com; s=arc-20160816;
        b=O4LjM8lO1kynUn3VZZfeh+bO5Gawsk6/Flq8WgTqX3ZKpavFCfxafSP6+9jUkz/yZK
         blWrgmnFf3siICzpYknzXdrAja2UmW4Jt3ZWdLZfJ3CpCe058DWuM13zrTUFbxhHGi0B
         6vocwmmlIkaB9Awd9VQ0N2hn7AugVOkrLGtfL1JAY/z2vRQRLTW3Lxe/kEUrKcVzA1AY
         AREiXA6rGYCkXmIr9A5ImgLMcTgsfUCGRQ68WBJgU2JXBA5/vETiCqo76qUHV3CbKJTs
         nYpUQtS94ieyO5Qs3U0yBNdweyr4MhP7uHg/RrMjm/qvQzRHZUiZS2XaAo5RsXe9dqS0
         3uRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5Anq1qwGKoGsIX6kb9ZWLK4o9JgSaVCCm8wVkC+oVCE=;
        b=0h5QBMd6Jac1Kvt1rosLbMg7qMZtUbwHtFl2GnpI4vEzyi+Mp0XknYfWWXknxnj3WX
         F6oYxvg3JgZmNqXWSBxDjoYQh7p82s5oSlVhy++OSus3OtuxEjVvIt7qAFl7jfu7+pkb
         8FH5UBwWPNpeWgLBLvuoVTLZaJ6Z6GykhyuQXxhqJRveOaVDUSdV0YO8iNuQCF2sIGcY
         /bPUyIln2mY+yfIn7wlNrvWV/RlwgyAc1880Q6opRSv9So9tCRM4R7onw4BtAzn0ivt0
         grIhPlRztRAvRoumZSvneTBRShkHt56qhmyD3F/Giry5c5NaiA2spIojld4qAuZ3jqz7
         o5LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=AUfFmnK9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w137si1181664itb.114.2019.05.28.01.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 01:01:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=AUfFmnK9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=5Anq1qwGKoGsIX6kb9ZWLK4o9JgSaVCCm8wVkC+oVCE=; b=AUfFmnK9XzeNtgYFLAw32vYpg
	uHV8PlXfVQ8TVUhu+7QmSiTGyVi9+JtQqh6ES2ANR77xHCPHIea/pNle1cd/kpxZs7jF/S0QPtYlh
	4H+WGxCtJ588MjkDyGPi25GnNQuQ6g0qkn/2A4IAemeQAWpii2+4Vq1yDIzJBNuVQ17tCMsnWghwR
	HgA0EieTjD/ELwj3HL9UR3qjzAUkM6i47p4SCrEPQGdRwT0hS8OUEDiwEWiZQwRde+rmtEoPmOP46
	GWKL83J16ZVG0bJYENsh+lIg5TwAG7fYcaMCjxdAUejy5dczD2i1PVruv7VulObHGR+3Rk7oDE+uS
	eG/JZb/bQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hVX3Q-0001oC-40; Tue, 28 May 2019 08:01:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 8CAA52073CF8D; Tue, 28 May 2019 10:01:49 +0200 (CEST)
Date: Tue, 28 May 2019 10:01:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org, luto@kernel.org,
	dave.hansen@intel.com, namit@vmware.com
Subject: Re: [PATCH v5 0/2] Fix issues with vmalloc flush flag
Message-ID: <20190528080149.GJ2623@hirez.programming.kicks-ass.net>
References: <20190527211058.2729-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527211058.2729-1-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 02:10:56PM -0700, Rick Edgecombe wrote:
> These two patches address issues with the recently added
> VM_FLUSH_RESET_PERMS vmalloc flag.
> 
> Patch 1 addresses an issue that could cause a crash after other
> architectures besides x86 rely on this path.
> 
> Patch 2 addresses an issue where in a rare case strange arguments
> could be provided to flush_tlb_kernel_range(). 

Thanks!

