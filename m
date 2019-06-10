Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7203BC4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:05:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 333C920859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:05:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="THqierrQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 333C920859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1C416B026A; Mon, 10 Jun 2019 16:05:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA6346B026B; Mon, 10 Jun 2019 16:05:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF7D06B026C; Mon, 10 Jun 2019 16:05:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 754776B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 16:05:13 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g11so6303514plt.23
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:05:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SDJkH4jfcgPMh7365qFs7O9vGK52Vn9CaAU+Zd5lvW8=;
        b=iF1LZVhg8qz0qF/9195K6dF6E85U838VStHc7W1i7nDMtlnAmQKlsTFHm2sIPBS+Fr
         mvPIb+LFp4gY2ViH6B38z2bPnd5DPQrg62GhAnm3gmkRcosFZ31BXqEfMHvyskP3KTOY
         Lcx95hMAkiNqf5QqLGFv94H+jWtg2pXt0fhY/my8eigtU73l4BYj9NYyPekt7Smhtev2
         Ebf61l4QTW5DdYp8ndBv9qXMluu6vdzK6o6NaNi9bzVkUQX3vI+4fnRlevMLYPpK+AjB
         0c0b/hZ0ccwqY5KfxTc009yT+BPMqBcw4fTxw4qBTmI0yE7hR+y2rGHyA2LtpNk562qu
         CUbg==
X-Gm-Message-State: APjAAAVYoH4ToG18+AuB0ckaXqH6v3aAUcI1JNeS8RaSxcH4No9nkvZi
	1CvkwXWcd6IBSMR32P2a/Feqql0NA7jwBepMiM7+Yr4/KYtnmJ4LupLYjj+GVI5xIez4MxuBrZ2
	6M8yRUXGqcVgbQh5mUMC0IxdlPzD9UU4Z4Gny2sQdfgLxE+pjw2nFac6hy9xnquIv8g==
X-Received: by 2002:a17:90b:d8a:: with SMTP id bg10mr23076214pjb.92.1560197113128;
        Mon, 10 Jun 2019 13:05:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJhXCqPaNzCocTKrS0gYX0S+oKfWxHJmsNVk+4IRzEKWsCzs3htTtJAQrbr2v1nYoljWeF
X-Received: by 2002:a17:90b:d8a:: with SMTP id bg10mr23076143pjb.92.1560197112283;
        Mon, 10 Jun 2019 13:05:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560197112; cv=none;
        d=google.com; s=arc-20160816;
        b=0SAuDB2znhqrRnpfH2FMydyrXXNXqyW9sDxCoGpyYp/fute4dIerJK1w3s/yKR2ibD
         LxifGho/ttvnjV7yrDD1dW5YH1x9PZ1625amuMahDdWL7WSVaIOoruu/dk5Zc5oCQxIR
         aBPcryOJ1iwG9DkR++BgiElv+CdkM037hY/VUnAFCdq17b3mwR1pS8e64X4BjqkDdixq
         doHBWAl19AWH0T1L8xdJZDYO+bNDhj5Ael1IWxB0ewDaVdBnQ4A4JTaD6BfK98+Li6wr
         DDQ3dgkPg7UXbxFqfhm5zlBOV8VJcPkFt5bG2ZHcpj2RvhKdHkDTPVi4pKY6pAJUKD7F
         Lt3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SDJkH4jfcgPMh7365qFs7O9vGK52Vn9CaAU+Zd5lvW8=;
        b=wwkV2Cv1EqvF9uCF0nFg12hb4d1E0W3cEuqHcJXbbW3FfH8/JYyQlDuufeHLC3kO2E
         dsb9b6YhZ7kn8/F76xyHlotKkjLpF83cKNGlajxHv/WZdbs6hTELuGmrhkLoaU+vddqc
         7r+hFNchjYsxjQmCLZrb1IG/N7IbtVuYe4XDGayWEyUTque5DHMAQceiQP7lW15lZ1Io
         jytjliVZa9WkIbsm6oX0RU1HpVizhLP7DjAcNUXlU+Yaj2VTg6XfUmsBgF0nh1ltoGcR
         0J5uPTyLSOnAZydP2tw9gUyFJSYIzcIPWe5fl7QQlmaO18Um9zWQKBATQe6yLacqC+rz
         7BfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=THqierrQ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w61si11680517plb.319.2019.06.10.13.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 13:05:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=THqierrQ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A8188206E0;
	Mon, 10 Jun 2019 20:05:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560197111;
	bh=PduZaRzQRSkUFp6m8ZuArUO0JgqoGEOmHa6pWYxRhLY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=THqierrQ3+YbCKPeWK1KP2EH89+NflIOBBl/puw8HhTzdGgC6kpn+afPni4h21D8y
	 cUPYgRp1SwvfIcbGjuZD/510c42MO514WgKmJwvDnF3o4XJwKjUM+oc0zmAwDDwSQq
	 GA3St+YuMNf3bmJYn7ZzZ+PLg5m1N7zCIehpkVHI=
Date: Mon, 10 Jun 2019 13:05:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, Anshuman Khandual
 <anshuman.khandual@arm.com>, Matthew Wilcox <willy@infradead.org>, Michal
 Hocko <mhocko@suse.com>, Yu Zhao <yuzhao@google.com>, linux-mm@kvack.org,
 Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] mm: treewide: Clarify pgtable_page_{ctor,dtor}() naming
Message-Id: <20190610130511.310e8d2cc8d6b02b2c3e238d@linux-foundation.org>
In-Reply-To: <20190610163354.24835-1-mark.rutland@arm.com>
References: <20190610163354.24835-1-mark.rutland@arm.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Jun 2019 17:33:54 +0100 Mark Rutland <mark.rutland@arm.com> wrote:

> The naming of pgtable_page_{ctor,dtor}() seems to have confused a few
> people, and until recently arm64 used these erroneously/pointlessly for
> other levels of pagetable.
> 
> To make it incredibly clear that these only apply to the PTE level, and
> to align with the naming of pgtable_pmd_page_{ctor,dtor}(), let's rename
> them to pgtable_pte_page_{ctor,dtor}().
> 
> The bulk of this conversion was performed by the below Coccinelle
> semantic patch, with manual whitespace fixups applied within macros, and
> Documentation updated by hand.

eep.  I get a spectacular number of rejects thanks to Mike's series

asm-generic-x86-introduce-generic-pte_allocfree_one.patch
alpha-switch-to-generic-version-of-pte-allocation.patch
arm-switch-to-generic-version-of-pte-allocation.patch
arm64-switch-to-generic-version-of-pte-allocation.patch
csky-switch-to-generic-version-of-pte-allocation.patch
m68k-sun3-switch-to-generic-version-of-pte-allocation.patch
mips-switch-to-generic-version-of-pte-allocation.patch
nds32-switch-to-generic-version-of-pte-allocation.patch
nios2-switch-to-generic-version-of-pte-allocation.patch
parisc-switch-to-generic-version-of-pte-allocation.patch
riscv-switch-to-generic-version-of-pte-allocation.patch
um-switch-to-generic-version-of-pte-allocation.patch
unicore32-switch-to-generic-version-of-pte-allocation.patch

But at least they will make your patch smaller!

