Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B80FFC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:21:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5873F217D4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:21:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wlA5IMAk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5873F217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC3F56B0003; Wed, 22 May 2019 15:21:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B73E56B0006; Wed, 22 May 2019 15:21:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A62CB6B0007; Wed, 22 May 2019 15:21:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD886B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 15:21:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 93so1911963plf.14
        for <linux-mm@kvack.org>; Wed, 22 May 2019 12:21:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=s0s9hOakU6c7ONxSQh7jsvM+l1f4GSzFc7DHVYRkcE8=;
        b=KuFeb9oY4In1A4FZevnEujwhuakO5V/g7QAemd7DjCnRWTOW/rHtHy19Q8Nxr0lrOq
         JaRvmWimKZgv5UWqesrvnqZH0Q3eJhxYu122wPFxEW0vrZqT65CvZByQYKEwtImm8LpT
         ZPXdVos824BHjmldQdlKR7tfknz/hPXb/zvUj01CXK3QWAUYTSX6EASCayKX13+Mi5QT
         6TBy387/i2G18sEIu+hjtrzaQ/98XClxEv8JlD5pDfunQVeQb8A2OCxPxBXbZ0BgVNUu
         soQvs/BMYC3HY5wX5SjJPLkQ/WTEV1UNrDsgB9ANU7IAYcHgU+eFtRh/WyXdPxzAnSAW
         0gLw==
X-Gm-Message-State: APjAAAWySf5FRBYruEqp/a40V7zaWd2wjIDujAk1f4ZUPXaRqXKVdMXC
	EI0h80rp1FBR73JH0lJV2APbFQw1HEZ2SmJaP5b7Hm2+6NFCDzCcgNLlWhVwm1xdU91MQkGhNEy
	QTm9i2cK5JA95RRlS21rZEKAHyv494jSfU0eWG5PasOBz8EYhMZ5SCA3z4zDsU7T/FA==
X-Received: by 2002:a63:4d0b:: with SMTP id a11mr4505173pgb.74.1558552877968;
        Wed, 22 May 2019 12:21:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFBcDcAziUe5SFGK5+7kmzV9nmAfRqZV6kCi+slqhBdae2LDOcfltgg1I2Jx6McH/K6COY
X-Received: by 2002:a63:4d0b:: with SMTP id a11mr4505015pgb.74.1558552876024;
        Wed, 22 May 2019 12:21:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558552876; cv=none;
        d=google.com; s=arc-20160816;
        b=k2bPnC9KquEzYbbn4Qr/A3nhMCRGIg9IWsEPd80GCtOtMpSI/tb+CY81juSfVCdAQD
         m40Hxyesaf+ZrvySM6BiMh+JV1Dmd/OUxIooWpxjYVTrLSjk2XU5MW9CqMO3uJQhbZHE
         tVI8BfMwaB3PsSXsve6PicvY/dWWChPULoDrqBknaH7eG72Vsqu+FWeR0FhUCt0h+x5H
         2G0BXPPx/Q9JEgBnwtqPBfOGz9DADqOuFXISifOSZ4agUrm+BgBSmzxslFy3NsCkfLuD
         /ommBRjYb8FkLinhrz/YLpszWn1FxlbcqsDXbaDUbvXcXdz+L/cTQVnWfXM7D8th7Ay1
         TvRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=s0s9hOakU6c7ONxSQh7jsvM+l1f4GSzFc7DHVYRkcE8=;
        b=Hi/l35ZKu3cRhiIzxIo/2MkuITEbMOpsoFt13S8oye5vBWxl6EuknValDmRp3TBpZe
         QdK801jJGTbmNI2hIx6PucKakX5ovdFnqedwZRj+GFray5hRGZ0gKcXUSsx3iJPrXFqs
         SBfTv7EAwiNsTNC8QscnKIEnoCxXfQZX4sQsWtYUOwJOrXKMr2VRv0cUjgq75RcpaYD9
         tfzEB0YrycLAVajQ8kzlo6kxMgSYSJM8vsE388gQD/7SO2YBlo4a/JvGBQ3SifmvloxK
         35X9AuSFrwkRpFqqpf2C+hsLvnlpwMz3Gz3FNHtzwdJbTGteAic5xCAxiCH37ARQMyMG
         8dDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wlA5IMAk;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f67si27458568plb.439.2019.05.22.12.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 12:21:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wlA5IMAk;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 523F120879;
	Wed, 22 May 2019 19:21:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558552875;
	bh=YbWw5jCdlVSPKASk0Am85SMF0LzLvtSiYq/4581+xHE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=wlA5IMAkbdJJK84FwgfTk9vb9mKRpiUrE0gdmAYhRNeZdEZWLa1O+1TqMzYFFDkfR
	 m8FRQRwg28nthhrzfBj+wuGjErUBKAjaQqkxYOpUwt4Yv2Q5F1PzzdjoWN+gmExmTD
	 OETzWa9p/CSYA14EHx9WnsYDpghD4UP96mMh+maQ=
Date: Wed, 22 May 2019 12:21:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Sebastian Andrzej Siewior
 <bigeasy@linutronix.de>, Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
Message-Id: <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
In-Reply-To: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 May 2019 17:29:55 +0300 Mike Rapoport <rppt@linux.ibm.com> wrote:

> When get_user_pages*() is called with pages = NULL, the processing of
> VM_FAULT_RETRY terminates early without actually retrying to fault-in all
> the pages.
> 
> If the pages in the requested range belong to a VMA that has userfaultfd
> registered, handle_userfault() returns VM_FAULT_RETRY *after* user space
> has populated the page, but for the gup pre-fault case there's no actual
> retry and the caller will get no pages although they are present.
> 
> This issue was uncovered when running post-copy memory restore in CRIU
> after commit d9c9ce34ed5c ("x86/fpu: Fault-in user stack if
> copy_fpstate_to_sigframe() fails").
> 
> After this change, the copying of FPU state to the sigframe switched from
> copy_to_user() variants which caused a real page fault to get_user_pages()
> with pages parameter set to NULL.

You're saying that argument buf_fx in copy_fpstate_to_sigframe() is NULL?

If so was that expected by the (now cc'ed) developers of
d9c9ce34ed5c8923 ("x86/fpu: Fault-in user stack if
copy_fpstate_to_sigframe() fails")?

It seems rather odd.  copy_fpregs_to_sigframe() doesn't look like it's
expecting a NULL argument.

Also, I wonder if copy_fpstate_to_sigframe() would be better using
fault_in_pages_writeable() rather than get_user_pages_unlocked().  That
seems like it operates at a more suitable level and I guess it will fix
this issue also.

> In post-copy mode of CRIU, the destination memory is managed with
> userfaultfd and lack of the retry for pre-fault case in get_user_pages()
> causes a crash of the restored process.
> 
> Making the pre-fault behavior of get_user_pages() the same as the "normal"
> one fixes the issue.

Should this be backported into -stable trees?

> Fixes: d9c9ce34ed5c ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>


