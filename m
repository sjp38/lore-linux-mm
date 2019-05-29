Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CFA0C28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:18:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04841217F9
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:18:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MUfztLfM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04841217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 942EF6B0273; Wed, 29 May 2019 00:18:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F2BE6B0275; Wed, 29 May 2019 00:18:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E22D6B0276; Wed, 29 May 2019 00:18:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 513586B0273
	for <linux-mm@kvack.org>; Wed, 29 May 2019 00:18:29 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d125so937222pfd.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 21:18:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eTnQiholZFye1OSgLNMpteUz0lkn5MIeientRCbMpvE=;
        b=NebQ9/pgJ9PPjYwIKtDU594vI+pKsiy2Ij5t4ePpiaz80/rk9T2rNriGKYiiKRYFFf
         aw6RNW1gbRU4Vr1X81xGsLnohoRL/bK4vt/+HC+bwsBPbd5Ifb0yRPK3KD6A4Mm7T8Bv
         P9BPumewJc1IzVl99rVgQnYbvOuG60P/AauLl2cPHezpNzAjvL03ZQIc2YzJqXw+cSev
         QZFLdiIvqaQEWWUww9SioyLkyde9DA2AGulZIIkHxXfE0zeMCtBru3ReWYlAcERULTzG
         8vT2gNiW2JeFpnWsjCA6BDI/BKjfAR87nDbQQj0KLSaoo2OrQMytHfwjLwztZI26iXJp
         3gmA==
X-Gm-Message-State: APjAAAX///peeizcDlse/1jzX5qVH8qXkZIrMiq775eoquluL7t2JH3g
	M2CruwGXSTOpW0/lQm97kX8Y0aOTvZX1DvwFldNXyX18s9NLgDues8lRvHXgBQA9CiFYTgTOkIT
	j9bmtX7y1wvHwIZXHcw2dyUhfLoe7aKiVu0D1vmXvtx0mviFAywKiLA+7OCbXJ5fZuA==
X-Received: by 2002:aa7:9a99:: with SMTP id w25mr53870086pfi.249.1559103508960;
        Tue, 28 May 2019 21:18:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn7LdPtwaQJ89F5WSCKy7ge2OqU+cWFgdT8tlvDGV9SivmXUlmgmDEcFHpvdoDsnyDBY1d
X-Received: by 2002:aa7:9a99:: with SMTP id w25mr53870034pfi.249.1559103508059;
        Tue, 28 May 2019 21:18:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559103508; cv=none;
        d=google.com; s=arc-20160816;
        b=RI45Q8lpyuVFjjNlWC7PIEMt2FWWvCvOsHRx8+jCsQmpJ+aps4UInnZ/t6CEQxuUC3
         h01nU21kyHRIIU3XJdzrZIJaWrdk/WViRDpne66kV6r/SM5rswgw/N3WdUL4cEJBwpiP
         mLkcTozam6bQuT1XCoXvycgmlIj6g8GELYrFxjMGzuhnsEzX9AA4fCC/JisMkmFFO954
         uAcYkOAzdWTZT8j2lRrAf/63AEVYnitIrE42IE5TdVa3eqWB5QsaRqwVhvvV8IFrmrW5
         UakAuJu13m5/32fBV2/qPjAMf/hvIZ/xs9aIxaMPxFhY81v3Yk+Oe4q0yyJ//+FoWOhC
         +gaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eTnQiholZFye1OSgLNMpteUz0lkn5MIeientRCbMpvE=;
        b=Yl8QPiaglVRCiafMolrcfiypNQu9H4rYcYhOzkDfohllU8ClNecW3S+EwahPLBEKDb
         cfR6fs/A0fIkkkZoAONzRLvOPjkUOkC4xXpT0R+f987n7hwXlK16At0E8uwqo4Dbk2xk
         h18kUk19CtBUeD08n3xN7JE/slN7oA5kZZJj5h8k3+GcnwwhsXPMOEKxn6QU8PtFaEwg
         1ZZgs12enttNjI0gBrUxRv6bRDlTSA2mlCnua1WI5uyzrLMy82Nf1DuuqwPQglunoFs/
         BIbBk/6sQdvMW7KLY1JtOqwr/5Bm2wyzHOSLVBPe4CH2iHAB8RkAElmTxBN+cEVIaMIi
         07wA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MUfztLfM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u19si23818804pgm.471.2019.05.28.21.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 21:18:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MUfztLfM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4A1AA2075C;
	Wed, 29 May 2019 04:18:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559103507;
	bh=UCoSBziCPhM34UxaNiokPrwVzYzZYIsmWDVJIPGcZqw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=MUfztLfM2HnwlYhIlBFmei3xc7llqPTTjMBONPqsdNnjQJyiPtGAm5eL19MlY5vzO
	 tSo0vVQTUBl6dwv+uKzb60PVt3IgWWRXIuAuk5bdbRQKY52JeRzvR0wdSTbNJnKlhg
	 JyDda8Z8xHZ757MndAPgkg0tZcdlzGV/mxV+4gIA=
Date: Tue, 28 May 2019 21:18:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Hugh Dickins <hughd@google.com>, x86@kernel.org, Mike Rapoport
 <rppt@linux.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, Borislav Petkov
 <bp@suse.de>, Pavel Machek <pavel@ucw.cz>, Dave Hansen
 <dave.hansen@linux.intel.com>
Subject: Re: [PATCH] x86/fpu: Use fault_in_pages_writeable() for
 pre-faulting
Message-Id: <20190528211826.0fa593de5f2c7480357d3ca5@linux-foundation.org>
In-Reply-To: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de>
References: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 26 May 2019 19:33:25 +0200 Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> From: Hugh Dickins <hughd@google.com>
> 
> Since commit
> 
>    d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")

Please add this as a

Fixes: d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")

line so that anyone who backports d9c9ce34ed5c8 has a chance of finding
this patch also.

