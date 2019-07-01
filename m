Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1341C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:28:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7885D20B7C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:28:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Wbfy/UDn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7885D20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14F656B0006; Mon,  1 Jul 2019 05:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 100D08E0003; Mon,  1 Jul 2019 05:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 015E58E0002; Mon,  1 Jul 2019 05:28:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f207.google.com (mail-pg1-f207.google.com [209.85.215.207])
	by kanga.kvack.org (Postfix) with ESMTP id BF7636B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:28:03 -0400 (EDT)
Received: by mail-pg1-f207.google.com with SMTP id m4so1824651pgs.17
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:28:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vGGhLIH0q7yG4i6ZhfftLCHdchxHJ/vmrYRS0LXQQIw=;
        b=Q1zhF9rSPnGNlIRenLc9FHiqYL9mTT+g4mnNH1mpDOS8jKdGUSxffup9yYkgTGwRTC
         CsTwtKnSta2PGdApWtCjuGDsLbEcD19FBcIE3xuwcippKGNYn+C2PR8EfQIkyNKtJum9
         kRn8OwyC4nD9JtGwoy+wmkCBK+CmWDWMXZBEPCX3CnxMlqbJEVs6El7LXt4FQooI8nwh
         5CxpcqFOfJvmabn9IykPFGg3mvCnn3ScstaD+M9H2VXx9l14ba9ghmW9Ybe9y6gDmkGb
         1X/QL/O60K2uRlMIlQIwa0PF39jGiz5jBVmZUvZHyvqW18Ha6DRobMYcDCCiYqhSlAw8
         ZW/g==
X-Gm-Message-State: APjAAAURp0NDlhROX5bBLzbDDHWvFz5K3ejeppwb1Plsa/pQ8gNc0ekq
	jU3xqKO23n3E0QgvlrlbtuqYnSIDh5WSe6gdS8C/zwQlLWY07eXpreDsnmVeThbv6aG6myBztQ1
	cYQKYR4WqWF/UZavM9o31rtNpz1HBfLxqSerZvUY0Ns+IC6x9zJ3s7oCqgLP7xqzcpQ==
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr29847189pjr.50.1561973283374;
        Mon, 01 Jul 2019 02:28:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhXLXTxWOLIVkfn5me+E15YWj+b+edTYSQbwlp+/T+fOBxxvn1AhRYx8eR4n/5bgCNrhS6
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr29847137pjr.50.1561973282688;
        Mon, 01 Jul 2019 02:28:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561973282; cv=none;
        d=google.com; s=arc-20160816;
        b=mk069zFSJPh2u9Nk/BqWa8MDMfBBbN3YccUrbm4hs66xBavfwv0illAElZN1J8aYBj
         nXEDgenXvchYJn0yFp76sGd5n1ZlcWe5qcEF0spXZULSAzZeaPdQ69UvEe+PYErNx7Vb
         N/EZhEiDv1j9+FF6MtNAzTDFDJuhJAv80eyQGM84QDesT2j2Ux+2lIHI0JdxM/YuIM7V
         bur5mA9ZGyGDBMMcyVgQHiLHnfaZkSavNc2wEqZT6N3ZfCXNe1DfboQHfWvTzUiZbAOp
         zAxYwGKjvnz2v3eOAW4YarmPS79t5ybQ7G+wF3OAm9YYsZws3rANIyKI1zwJseKlSzlk
         xVVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vGGhLIH0q7yG4i6ZhfftLCHdchxHJ/vmrYRS0LXQQIw=;
        b=hhR9lQHAmBwXqzp28d476oEHo/9bu4WrTGIDLgZFsNdDcdEnYR6DgQJQWdSzN9OaU9
         K3Q6WekBav5aLVhR9gDfZWSaRraDHElw9bIhEhDi6bqxGKb5CUxKI+GDpupyHQbBLPte
         WWtkmVdXNcIWpx5MKjFEAls9HvVVISAto8qXd6ySDDj6If0222SWB0UqyrURy1XSNg19
         63xJ75pBH/Wt5uHEaZMStmdA0wwg+6YCIzTEVAuHIQYxjxfSaPJSM+dnYmtvv1dtC7wv
         K6+E+cZfFytlruTnsIsm3G1Z5ypN2GD4vJXMfjbJjzqJ7e49jPGOgwa8VR4BDMlAzmy5
         Wo2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Wbfy/UDn";
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o3si9214052pgp.183.2019.07.01.02.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 02:28:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Wbfy/UDn";
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 50ACF2089C;
	Mon,  1 Jul 2019 09:28:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561973282;
	bh=vGGhLIH0q7yG4i6ZhfftLCHdchxHJ/vmrYRS0LXQQIw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Wbfy/UDnFu7AV7EVkBeEbTEFUi7+cuNIjsKmOymazsu3SH1OX8v5r5szm5MXCfGmu
	 RH2qxtH1DohcNqBOMBm/SXfrp+lwiclFgsHSKwXOefDBanFU9uYc17ezhL9NTuw0cM
	 zF4ZrwabN0rIsBtgDIHHd3RIrWasEIQkBmhR+8nk=
Date: Mon, 1 Jul 2019 10:27:57 +0100
From: Will Deacon <will@kernel.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm@kvack.org, Christophe Leroy <christophe.leroy@c-s.fr>,
	Mark Rutland <mark.rutland@arm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Will Deacon <will.deacon@arm.com>,
	Steven Price <steven.price@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH 1/3] arm64: mm: Add p?d_large() definitions
Message-ID: <20190701092756.s4u5rdjr7gazvu66@willie-the-truck>
References: <20190623094446.28722-1-npiggin@gmail.com>
 <20190623094446.28722-2-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190623094446.28722-2-npiggin@gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Sun, Jun 23, 2019 at 07:44:44PM +1000, Nicholas Piggin wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information will be provided by the
> p?d_large() functions/macros.

I can't remember whether or not I asked this before, but why not call
this macro p?d_leaf() if that's what it's identifying? "Large" and "huge"
are usually synonymous, so I find this naming needlessly confusing based
on this patch in isolation.

Will

