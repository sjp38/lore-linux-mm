Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FF6EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:54:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C924D2084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:54:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="F2Z1siwE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C924D2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 340AC8E000D; Mon, 25 Feb 2019 14:54:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CA268E000C; Mon, 25 Feb 2019 14:54:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BB748E000D; Mon, 25 Feb 2019 14:54:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id A092A8E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:54:13 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id z15so1607602ljz.7
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:54:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NMjSLSh3kp6WB7h5Y9AuNjxZZ/9KcGlk9e4LZplkaBE=;
        b=nv/Yvx3HM3nl4rndexy2RsTpFegiy3Z6MOndqFiKiCa9ex0Qfz4X97ly58+YNiqwPu
         WKxiKJdl6e8/v6/94a0livIjgrU92r8XUr/hxPnjS8drdqc4ASBVgvqB2wxQRN1hH46/
         94fe5gl6w/VjcTkPUU3bOj5QosL5eu91U7aUzS+byEY384QczxYoGtmCTqmjy8xQGSHM
         hIDGRwrrfuRSN0RmB7NWpm8kyNMldCrm4IOlkiQXQ/5AjJWIZzV6ql3Jcttg/8s1ycQV
         08z830pRRS3yf1lSEq4/Os2TRa0B8SpztwgK6F2/oqU00JDJ/F915JBmJ7iEynPn3NzJ
         Ulmg==
X-Gm-Message-State: AHQUAubW3ygMS3qUBZflxjjzssgPcJLYp7sgdAb6nVf1OqyF3YFgoW2c
	ovd1mAhESc5GR/0fjcIqEAPAJV6bS7KvoZjim9BcDJwtLxN8+C4j85UvUa7aZesSpFf4rAz3pha
	OQGqa9yjzKWEtoNRdK6Ewn2XJk8stUTP19UvZwBK3V2YqqSpYK5ZwG8IxBglAVZE14OcmwzqpdS
	E9K52Tkn1a2RMDgSHXcfWPU+H9IFHK2uORqKnO/+fBajTP4GHayGN7TUgSwviUH6oPt3JJkPc3Z
	MyI5BjF1tYNSswWkFPQeGQ+SVTsSqJROYryRREdJ5r9YcNCQN4Bi0r5MVo0xeM6Uw1UeB1RDMs4
	Y5+wbXIR6EHLi/vybNjNBViN3UvBAd/DS4VQJcaFp9feuNIpjh81o62J44Gg2Z/XcLMzmnRRBWK
	F
X-Received: by 2002:ac2:52b7:: with SMTP id r23mr12000829lfm.66.1551124452877;
        Mon, 25 Feb 2019 11:54:12 -0800 (PST)
X-Received: by 2002:ac2:52b7:: with SMTP id r23mr12000788lfm.66.1551124451799;
        Mon, 25 Feb 2019 11:54:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551124451; cv=none;
        d=google.com; s=arc-20160816;
        b=iBVyvTipEy40jAV+LDtbsDM943XR70DOCTxKh2Zu6p06CfbkSnGSbfgj2pN6YlDpHI
         6Eqf3rur2UMR+LxT31SNjuco9cto87uq1H0CX/BesqXG9JEavUuA5zqiN3X6IolSmDTz
         NJStAIU/SNDYwB9Q/t39huoQJkRYlh8nPKLlG67aQdLqwXOtXx0sBIzNMTnoy7ooD8cr
         UNYLk4Tzfkcl44NOoNBEcOvcBfOy3mf+ceX3L4TlrBw5FCp//xc3EWK9rtsMU29UFaaz
         p/ILsGaDW9ruzaKdEa2x5qF0kkGhf60XOMhWs1Uwn3ycIfHBYq2nEsA6FGqpCohWkyt9
         ZpOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NMjSLSh3kp6WB7h5Y9AuNjxZZ/9KcGlk9e4LZplkaBE=;
        b=GB3tT8viHX1CyIqwabsSHkw+ur//CA1MKfi+kib0vut0GTu73UUamGBDPVt5oX2ior
         CF//WzJP6H3R2fpHPSq/VbyX0oF8JP9FqnEA2TOk3XmBeRuIYvixSHYKkyUntaS3x8Su
         rrVj1tWetvluxC95/asc+Z3KckrlryizZl0qoeXwqBChU8AtOaFZKzVeFPdsU6ucRRAD
         7yultatHxgz1zBBWnq5026/O/UZ2o9aLjYfRpmYf+WovE152uWStVmdrnqv4rzGyxUqF
         JKmXF5rDU3PNyuVwgPSO265nFt5F6/XZsnruzQOM1DC/geShRelxyAq8EFi+ef7gb8XQ
         7iDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=F2Z1siwE;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u9sor2655508lfc.15.2019.02.25.11.54.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 11:54:11 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=F2Z1siwE;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NMjSLSh3kp6WB7h5Y9AuNjxZZ/9KcGlk9e4LZplkaBE=;
        b=F2Z1siwEJ5qc+oOUttqdscrbgsALxm3T8O/vOxq1if/vkdiJLNLY86YME4c917bI82
         VuttugCNtmEi6CzrZCyPzZLzA/YktR8+oMz8EO3tK0dR1oz/n0g5BVMz298PkeUDRdxt
         hV4MfN7wOXi0TdMHZ+OTZiDno30IadTVuUOOI=
X-Google-Smtp-Source: AHgI3IapoHIcHCHo5wutBsjXetCTBIHah/G5TZae4FiPu8Df/YCy41ktIOGwLBk+1QV3iWm4XYqQiQ==
X-Received: by 2002:a19:2396:: with SMTP id j144mr10440738lfj.159.1551124450291;
        Mon, 25 Feb 2019 11:54:10 -0800 (PST)
Received: from mail-lf1-f54.google.com (mail-lf1-f54.google.com. [209.85.167.54])
        by smtp.gmail.com with ESMTPSA id u15sm1560110lja.73.2019.02.25.11.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 11:54:09 -0800 (PST)
Received: by mail-lf1-f54.google.com with SMTP id n15so7830271lfe.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:54:09 -0800 (PST)
X-Received: by 2002:ac2:415a:: with SMTP id c26mr11947222lfi.62.1551124448787;
 Mon, 25 Feb 2019 11:54:08 -0800 (PST)
MIME-Version: 1.0
References: <20190221222123.GC6474@magnolia> <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 25 Feb 2019 11:53:52 -0800
X-Gmail-Original-Message-ID: <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
Message-ID: <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
To: Hugh Dickins <hughd@google.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Matej Kupljen <matej.kupljen@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	Dan Carpenter <dan.carpenter@oracle.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 10:35 PM Hugh Dickins <hughd@google.com> wrote:
>
> When we made the shmem_reserve_inode call in shmem_link conditional, we
> forgot to update the declaration for ret so that it always has a known
> value.  Dan Carpenter pointed out this deficiency in the original patch.

Applied.

Side note: how come gcc didn't warn about this? Yes, we disable that
warning for some cases because of lots of false positives, but I
thought the *default* setup still had it.

Is it just that the goto ends up confusing gcc enough that it never notices?

                Linus

