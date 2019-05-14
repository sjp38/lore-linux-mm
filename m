Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1103C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 11:49:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B29B20843
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 11:49:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TIFvPOXm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B29B20843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1119F6B0003; Tue, 14 May 2019 07:49:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C20A6B0006; Tue, 14 May 2019 07:49:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF0B76B0007; Tue, 14 May 2019 07:49:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id D16346B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 07:49:29 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id v22so4456165ion.2
        for <linux-mm@kvack.org>; Tue, 14 May 2019 04:49:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3byTOZ1Myj651NO5kaGAKud48ExIes5ZKoTARDnqAyo=;
        b=oVeBNj3FbjWAZh+vMRQgcHraUnhIVQEDxxjMbOOLuKozntS7OCbFM9uT5371bBqMIH
         OPrv92uOdKSN/wJWQ5RVgQOgf06OKqjjmVwgAHmAOUQrUpL0VV7GATUx5mUM9A0USgSj
         xTvGxB+Y/2khZMPhRpjdKndNbaQ8/V/sIq6WuM/EKC8jai3XJJ8y1p7bM9lA+w8HcNLV
         GJGyrToT12rOSb5cFK03W1I4zRA/aXB1+b+Yo8Hs/TO06573K6u8NosVjBxP973QypTG
         s61kaKjmdXZNUtAMCQAeQWN0ry9MZJbN9PG5e/Ohr4qYpo3umJQQVVLCS7nyJ8e3F2kE
         UtVQ==
X-Gm-Message-State: APjAAAX0+vj4Y9j6RZ6sPVxlBDHalMLKqk0nIqDtcDv58vY+/JdJOfHa
	xd1aL1KvCdQDc1qran/rXhe1i17DS5CB6PaTwTGi+6IuwwOukke3v5CGEW1FzJttJraQBsSHCly
	rgGqk/bVivW/0W8YsN+NlHvpGkqZwMm4CGw9v7lMrmw9SVqoCzV5ch+pHc/Lj7ahzUA==
X-Received: by 2002:a6b:3ac3:: with SMTP id h186mr19443866ioa.63.1557834569612;
        Tue, 14 May 2019 04:49:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbUWcy2W6ndOQzkF41kOeafqwS+IhsSkce+EMtZm7EZV9iBnAg/jG6s69XHiyC6EB2D4V/
X-Received: by 2002:a6b:3ac3:: with SMTP id h186mr19443831ioa.63.1557834569014;
        Tue, 14 May 2019 04:49:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557834569; cv=none;
        d=google.com; s=arc-20160816;
        b=PvIAeFMXY5QD0XKeRwqXxznXAvo7dOxfKfXIOeJbMVyXxp7QSleHjLCI6Mnh1P+Ghn
         1vatbQiHnrrbWvWAeze13+OiWmODK7eix2GejvHsmOQ/VPrIgazbA+3i+ISSA3G5h0m2
         quy2Ctj8ZodyNvN0WdcTz9old5c6hrChPYb8LKq6S33NaQ4cBwwoiVgzmf91LYYJoZh0
         EUcI79h1gNr0w97375fDkGqzZxUgEbuG0No/eHTlA5hUM2gIsNiUFvywaJ1hBA6BDAtV
         WDUulzKgqbX0WGdpGzv8BSeYeTAea5OLWIwMJ0Y01fc6itX851u/39TjzFkYjFiDKPBg
         jh7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3byTOZ1Myj651NO5kaGAKud48ExIes5ZKoTARDnqAyo=;
        b=txo94UhF8a1Uwpk3WTM4QCAnhpBnLQQMFyjbEMiYkGv+/SqAxeI3WF+Vn6/Ef06Lpf
         bFD57GiRUsLC0sAmk/a3iUYuH2dvqi82U8ugERKWs+iYpHW0sbWMlAxHQsKOeV6QauPO
         yedYbHVAOXPhJ3vjHqhGsJQl/8Jb+cthA+LIEc9Mpb/HDxgSbGmXGNsZ2z42wNOQfvrh
         fRAQnNIajlygvL2SOGqXvnMfd6zQjMbPy3xwO/IoRK93Q7rQNGYCAz8zeQ8NRmXL0Fp5
         TwlnjNyu3rBteVhQy8Y4SrNxQAqTYu5VfIc8xGMohBfXy6OACZKkDG874YRpJM/Y9G3w
         Rztg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=TIFvPOXm;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 131si1322775itu.86.2019.05.14.04.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 04:49:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=TIFvPOXm;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=3byTOZ1Myj651NO5kaGAKud48ExIes5ZKoTARDnqAyo=; b=TIFvPOXmwezpA+bbGIElqbOPS
	66JUG+655NExwAETL/RzqvHaEYb3sfEKCH39v0eO2yBmUTwYhhKH/0qL2WXRI5bXdAScd2g51vxcW
	j+x5oGqRAo10u1XTDs7HX1CnF5hZQV5X1VTev28CWBcT9QTCeaOuYHYwKqr3HKXig1DGDS6VFgy42
	RH/v87y5MT3GWzAE7LaMPmD9eIFEkoMxeWIxz42MzdhwF9Yssn9pmMDRWrYEdskVe+PLq6DpHyUHV
	e4J0yibV60gN14RFX4NVqZp2TchwE2LNQZo3HGwTZbX7QiOEstYFh4hSbDe1/RAkI+LDyDilLes/f
	YS2aaM9pQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQVvs-0007hN-GB; Tue, 14 May 2019 11:49:20 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 441122029F877; Tue, 14 May 2019 13:49:19 +0200 (CEST)
Date: Tue, 14 May 2019 13:49:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: Jan Stancek <jstancek@redhat.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Will Deacon <will.deacon@arm.com>,
	"minchan@kernel.org" <minchan@kernel.org>,
	"mgorman@suse.de" <mgorman@suse.de>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190514114919.GO2589@hirez.programming.kicks-ass.net>
References: <45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com>
 <914836977.22577826.1557818139522.JavaMail.zimbra@redhat.com>
 <9E536319-815D-4425-B4B6-8786D415442C@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9E536319-815D-4425-B4B6-8786D415442C@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 07:21:33AM +0000, Nadav Amit wrote:
> > On May 14, 2019, at 12:15 AM, Jan Stancek <jstancek@redhat.com> wrote:

> > Replacing fullmm with need_flush_all, brings the problem back / reproducer hangs.
> 
> Maybe setting need_flush_all does not have the right effect, but setting
> fullmm and then calling __tlb_reset_range() when the PTEs were already
> zapped seems strange.
> 
> fullmm is described as:
> 
>         /*
>          * we are in the middle of an operation to clear
>          * a full mm and can make some optimizations
>          */
> 
> And this not the case.

Correct; starting with fullmm would be wrong. For instance
tlb_start_vma() would do the wrong thing because it assumes the whole mm
is going away. But we're at tlb_finish_mmu() time and there the
difference doesn't matter anymore.

But yes, that's a wee abuse.

