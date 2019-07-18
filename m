Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D914C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF9B42184E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:45:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="huhpkdvr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF9B42184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EA336B0003; Thu, 18 Jul 2019 17:45:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C0836B0006; Thu, 18 Jul 2019 17:45:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AFEA6B0007; Thu, 18 Jul 2019 17:45:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 412CF6B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:45:02 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so17347311pfk.14
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:45:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iAfMN0iN70l6JhGqYzxdhxWiaLpg1j0+D8clrhvzkok=;
        b=BHrKUFecsJUSlo3v0BixEBiBo3j0sk2lkl26Nwy2s29Otsxz/23PeTzmu3d7abJQOw
         WnyWI25JkgqDOx5IAgbuUvrbmIqP6UagDjtskhXENGwjFssA+nZU+WvDLLvK/na8IEOP
         VhUBw9cB4zFfbnwlQyetlYVGf6TeBX5Kq8b/ULH16vbtSUIBJP9gN5oWSpJPoHvWb/3x
         cutiE1LhIrsNYImC8XpetY9+HIcaXqEuXbFw6tlw/RaNRLPLReSOWPhLFEAB75iYBl0s
         YImNByE+CsODgyQYWYexolp8S3r1RJ75pXjapbghPggr9JNicpjwv+b6N+hFm30uA9XY
         2c0g==
X-Gm-Message-State: APjAAAUZT2T+/oO7iIKqdlODbomUBa4dNXdtnIYfFZMtyDzB5R6/0NLT
	ShQouXplURsrQgJmkfE4FduZjnhhud3CYEb+XKRFvIwlCX4LilqSVe0gC4eg2IRvSTHsw6Ukr2K
	X7OAlqSUjW0oV0CU9uBZ5HxksuOz4PrpWr6Qwfyarpi5lKQQUieFO+LayFPdw89ER7Q==
X-Received: by 2002:a63:5550:: with SMTP id f16mr31886227pgm.426.1563486301819;
        Thu, 18 Jul 2019 14:45:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlU2rU9NVAY+vmfnRzdT0zhbc9Xvzc2hm2dkNwOvxz2xD6PferkNaRxecyT9Yb4Q9OIoIT
X-Received: by 2002:a63:5550:: with SMTP id f16mr31886158pgm.426.1563486300863;
        Thu, 18 Jul 2019 14:45:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563486300; cv=none;
        d=google.com; s=arc-20160816;
        b=tS/DHn3/x4TfAJLKPLCj4Zr7mGjUS+T13vLtusn5XS8j3ERxKCiFMPanPqTdsatzbm
         ZejHmdqgziJscpXOzrahYpsxW80jMHoe42utWEX/3RXBemVLXtJ9R0oYd4EtwEluakHJ
         hNoRsAvTyrbMYVPP5t9fBx717uSWXrlDTqH3rl+AJUSBmyaeP26nHLd36O03l2kjovIz
         r1fQLh97IosRf7tueKbp2Ds3v0gbWKi6XnWINecpvgUrQln0dcmjureQ+LBudYdBYphc
         K6BF3uc+8QQBs6OkjPxD33jc/5j8MMrlRAmXSufHkdEZm7w0gQIkhbEoVBx4izVp9S6x
         +4rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iAfMN0iN70l6JhGqYzxdhxWiaLpg1j0+D8clrhvzkok=;
        b=zQwxcHIh8JkastHw0md/TmoGN/2+CZiVgPMHvhJJQzK9xzStkPNmdIFzrWhQgW9Wox
         O72pHINOAmni/zDenpM+0G4n9P8+blWTxs0AOTVl5hytQVEYn3fJ55WrL8k9ENwohG6v
         qthokd9/3nflHnAAPE23eMvJfdIEfEqfQjfeWkjpil/jjQjp2rt/21FPeRmt7rmnK9Hf
         1dv42fqlMZ2iGOQA9BZdHM/BR+niaLRu6lROEqlMUwMwU4glr0HMGY6glRoChkWKzoIR
         RxXjdPEowe++Wiem3H8IlvaYOzXcOuekdE+I1Kurfj7ZJntkez6t1Tir3PWIlX5TrEZb
         J5QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=huhpkdvr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n187si1300538pga.165.2019.07.18.14.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 14:45:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=huhpkdvr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3875C208C0;
	Thu, 18 Jul 2019 21:45:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563486300;
	bh=AvFJMXMixH9pwAZAEJiAZGH5BdBKz6e6rNwXKbc10vQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=huhpkdvr2Y7vQhrHeuDIvSjajTwPYanZe0q2sPxAQRnBrgSKZ6zEd5/vzFjiv3Px6
	 occ2gbieMwwsnJWBjF/ZVOLPIcJNzWVFaCFwlcdSojX4q9Oj8RbROxWnRHELdAAXDx
	 WiLHeAEsTgwwQxf8M7bbAA+8Gd2IDWrbC1qldSNg=
Date: Thu, 18 Jul 2019 14:44:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, hughd@google.com,
 kirill.shutemov@linux.intel.com, mhocko@suse.com, rientjes@google.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 2/2] mm: thp: fix false negative of shmem vma's THP
 eligibility
Message-Id: <20190718144459.7a20ac42ee16e093bdfcfab4@linux-foundation.org>
In-Reply-To: <5dde4380-68b4-66ee-2c3c-9b9da0c243ca@linux.alibaba.com>
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
	<1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com>
	<4a07a6b8-8ff2-419c-eac8-3e7dc17670df@suse.cz>
	<5dde4380-68b4-66ee-2c3c-9b9da0c243ca@linux.alibaba.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2019 09:28:42 -0700 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> > Sorry for replying rather late, and not in the v2 thread, but unlike
> > Hugh I'm not convinced that we should include vma size/alignment in the
> > test for reporting THPeligible, which was supposed to reflect
> > administrative settings and madvise hints. I guess it's mostly a matter
> > of personal feeling. But one objective distinction is that the admin
> > settings and madvise do have an exact binary result for the whole VMA,
> > while this check is more fuzzy - only part of the VMA's span might be
> > properly sized+aligned, and THPeligible will be 1 for the whole VMA.
> 
> I think THPeligible is used to tell us if the vma is suitable for 
> allocating THP. Both anonymous and shmem THP checks vma size/alignment 
> to decide to or not to allocate THP.
> 
> And, if vma size/alignment is not checked, THPeligible may show "true" 
> for even 4K mapping. This doesn't make too much sense either.

This discussion seems rather inconclusive.  I'll merge up the patchset
anyway.  Vlastimil, if you think some changes are needed here then
please let's get them sorted out over the next few weeks?

