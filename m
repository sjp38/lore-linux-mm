Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6118CC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:10:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 226A3208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:10:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="O0oO6ADu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 226A3208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1C5F8E0005; Wed, 31 Jul 2019 12:10:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCC448E0001; Wed, 31 Jul 2019 12:10:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABAE88E0005; Wed, 31 Jul 2019 12:10:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72D6A8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:10:54 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b18so43162944pgg.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:10:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=I4ZYaIH2fTusDeJ/+ZczY8t8hDSjGaMBBYwXQTPsv1A=;
        b=CSeoa6rCTh2P6JKQdNAhmualnbcI0QSfIThfedra9hdbvhAO2QMOpBHrreVgS8cJS2
         MW06RqGXR2aDqS64w+EjsjMTLv25+/2zz/tdME/rxPWqBzC9nrKTFdkPnyyldGY88Sgd
         u09dFmuJx4BgazEXeLn82z6ak3lLuWMY3cy9OL46q5BieE7YdAhyr5IMpjazRYmv0R/N
         buFGKkbFTVoDLy5pulLMPcJHdO7lceJ58rDaGf3BYW2ob4yOzYQGckMBiZwVJr3IMOtt
         am57xkk8JsNHRIIjl4/SCUtER3knL300bRoKIiYi3yZpuUIceT+lyOWRkqPO3a3ESXIR
         879w==
X-Gm-Message-State: APjAAAUrJNwJcgCkQLbH2r68XbxSOtJUlXrdQJNjdfAwW9zFUSwq2WZk
	dtRg4YzCkm/8zVayNLHt03hhKxKZX6v9TbAKlm/b0Uxu/1czsKTj4tvvFmeHSi3TE5mzQqxGR0Z
	PAAuse0u55BpLnWLU0VgkzL46+/47vbykC/SBx32Y+rgwlRApanDMxi7vzlwPdjzIBQ==
X-Received: by 2002:a17:90a:c391:: with SMTP id h17mr3750056pjt.131.1564589454071;
        Wed, 31 Jul 2019 09:10:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2kNC8GiZJgzz3gh8zKmP07VCI19iKuD2Fplm5tI6rsMJxwWTZi330P6JVnIqPlFTRRMQC
X-Received: by 2002:a17:90a:c391:: with SMTP id h17mr3749997pjt.131.1564589453361;
        Wed, 31 Jul 2019 09:10:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564589453; cv=none;
        d=google.com; s=arc-20160816;
        b=bfqr9vqxvnbkP7PASIch/V+9ihATydtmTafuy6e6jyLsnQyqg/rFTIXQ2bemlGRYmr
         r4sSdKLWg2GZxYaRP99nJFvIKXSEJX39sVwtgfJ/sNfa1O3bpyD0+8y2lGikswsw+laf
         NbLRtWad4VdzXvV3iiXF4jRMnJCegrdH0WXS4lbgn9nPujb2eWxuVlzsxrI8iGU1d3Qw
         csjxj+UIolYgHt9h1sdutue9Y/QnGAibciYcdGVuoLl8fTIPrQiCLUQCVhy/aNkvTlyK
         RH5XAGldAVjjX6wGgovvprGKzq7Z0kIpYLFLx/k7Jzi0Cag0UQefQ+zNmtDzBVIogd+d
         tFMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=I4ZYaIH2fTusDeJ/+ZczY8t8hDSjGaMBBYwXQTPsv1A=;
        b=BBxM6C4F70LAsQ3nSbpJ5lBlbTyHUMEW5h2G262thc90eeI1OHGxEmcLWYQveiIMXV
         Z4jM7cLm8EnmdKYhc9p8T+e5i7orDjbo9S7kQq+N1IfF+b+oVOXcfhMbrfdI4uAmmOlF
         lg3ybjVIrqN/OCwtNEwPCqPVsw6l381MXu8yB+kSL3zZvZgo16mpy2VGUbFi/EPLEqyX
         onGD4F29LZRaE7ofvRtXwRrCYKQUc0oRzLt3RTUGrKTYCjvPtRdmheVpiZGRTj/L4sde
         XXcZrxtNUvHOYOe5KqWk8JmRjvYEc/TIncpG0OEsoL5V3U2IJxYd+ywekseyfB9UZw+j
         QMXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=O0oO6ADu;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a1si1742318pjs.58.2019.07.31.09.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 09:10:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=O0oO6ADu;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EDEF5206A3;
	Wed, 31 Jul 2019 16:10:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564589453;
	bh=WCCv3Aec470dqenJ3D0yJXfNnDANp7cVqdAtXPLEgsM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=O0oO6ADuBpn0GsCzed/V3vKsIofX8heKLLg1altER77SX8nvqgWsXXTEM1v+taPPH
	 EIwclnx482U7aJLNBxzEszh8K/nBVMDE9WWJ3rSKcTQBSk8H0adilY4q0TaGfAK9h8
	 GAMdp9Q3T2fvoMqUn4p9KL2EwGx5PxfqoHpuEndc=
Date: Wed, 31 Jul 2019 17:10:48 +0100
From: Will Deacon <will@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Fenghua Yu <fenghua.yu@intel.com>,
	Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [RFC 1/2] mm/sparsemem: Add vmem_altmap support in
 vmemmap_populate_basepages()
Message-ID: <20190731161047.ypye54x5c5jje5sq@willie-the-truck>
References: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
 <1561697083-7329-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561697083-7329-2-git-send-email-anshuman.khandual@arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:14:42AM +0530, Anshuman Khandual wrote:
> Generic vmemmap_populate_basepages() is used across platforms for vmemmap
> as standard or as fallback when huge pages mapping fails. On arm64 it is
> used for configs with ARM64_SWAPPER_USES_SECTION_MAPS applicable both for
> ARM64_16K_PAGES and ARM64_64K_PAGES which cannot use huge pages because of
> alignment requirements.
> 
> This prevents those configs from allocating from device memory for vmemap
> mapping as vmemmap_populate_basepages() does not support vmem_altmap. This
> enables that required support. Each architecture should evaluate and decide
> on enabling device based base page allocation when appropriate. Hence this
> keeps it disabled for all architectures to preserve the existing semantics.

This commit message doesn't really make sense to me. There's a huge amount
of arm64-specific detail, followed by vague references to "this" and
"those" and "that" and I lost track of what you're trying to solve.

However, I puzzled through the code and I think it does make sense, so:

Acked-by: Will Deacon <will@kernel.org>

assuming you rewrite the commit message.

However, this has a dependency on your hot remove series which has open
comments from Mark Rutland afaict.

Will

