Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15E1DC46470
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 16:58:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C82E62173B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 16:58:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WvagHzfk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C82E62173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A1F86B0270; Wed,  8 May 2019 12:58:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52B0E6B0273; Wed,  8 May 2019 12:58:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A47C6B0275; Wed,  8 May 2019 12:58:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F36916B0270
	for <linux-mm@kvack.org>; Wed,  8 May 2019 12:58:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i123so8552237pfb.19
        for <linux-mm@kvack.org>; Wed, 08 May 2019 09:58:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=x2WuU/X5fa5tUVfwJobGS2HfWE2m292r4J/u47Wd82s=;
        b=qv5RT3O4x3h53KWQBWEYNrM1ta6YmR85yXbn6dTBBYmUSFzdCPahIyRHvHWQxsfLmO
         txcKBcJybe293RhonUP0wITFSLLaC1J1FWb+gBxyxWihgf3QUT4DtYxQcCtVtImYsN4V
         UKOAxTEUdyx8qxXMmftXu5hpHkz7aVke5OWH3r/KdjDNbhNYi/3NYjqNe6YgHn2mOPhw
         Lxs2oF6ANX1GPHBAJc56zf1bdn4F8DU+on4RLFesBpCtbnpaTHfzG+IVKv17gc9uJM8N
         73YzN8o92e7vxYn4RNJrmG1sO3lz9cI5dUXte/tUd/gQuK3GHwAZPrarP6ePr+ZxtJcW
         btBQ==
X-Gm-Message-State: APjAAAUHUZB0zgz17zr6w2+Jfv8OY8RZXolw+6rKNjTzgXqyEWKNYgFr
	VMvrMxjr+hcam0WHBIxdO4h/a/rfnd81jPkJtu7WW/ML7UoBMQQeS3sBUtzIAlugtKxd9DqdWQ5
	ziTSIyZwpCg5PPCMG34spiafSYMVshWnD1vo8HPWWzkbrsQZuCGjOXBUq4hRxKKBBSw==
X-Received: by 2002:a65:6655:: with SMTP id z21mr47853903pgv.33.1557334720628;
        Wed, 08 May 2019 09:58:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyX9MuznRWBWWaFbs6cfvMiy3ujgyHqtOEuNU2QcKjBsVdg01gmUj0GzWQ20mBSxQB8UQay
X-Received: by 2002:a65:6655:: with SMTP id z21mr47853821pgv.33.1557334719892;
        Wed, 08 May 2019 09:58:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557334719; cv=none;
        d=google.com; s=arc-20160816;
        b=Ta18BMj91mn7eSlP7ftqyhHG/ip0i/hY8ViTAEWXAkA1/hLm7ovvY9fudcUkzwghi0
         1yHl0gHFzizAZpxp7MAi2VT2c4hv0aDGHuJDkNmBuWFZNQ78+EWWIJ36yB/Rs1kd5Eo1
         Sdvs8cdznC4byxYWjrA59ffuH+6j3BW2UpDan2FmeubW1FXneEr9QO9zX9cFmU6x3hze
         NLbNO+CRltfqoZszTDrr6/MDn9vBdZHIbDm1tvdOjApVF6rVC7Q3jKJKcDf8cxIdzq8g
         C7kzQy0MwGyN39sQGZ9+/FKz99IdQDFAqu72yF7t7kqmhW244jEX+MVQNkXKnQZPxkvz
         v0TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=x2WuU/X5fa5tUVfwJobGS2HfWE2m292r4J/u47Wd82s=;
        b=WiOg5xpO9ImYpLNN/UpYgqJzHJE4f6QVXkmF8sv2n7TyvQgI909GRVXGuOg6pDQfcD
         s+KYMzSWQYdmv6DCACXAvuUg8RcoOPnYP/C0R3q/ofW2b1aXINs+qx9weGlHF6QNPZMk
         PtVP5t2WRjHL3sHUebFXLraNasTT+GyzdkmciNgtvopDV0BpKECs/dz//sCb863Qt3my
         6b5vnHYofe1INRRfkLE7ewOhvXOAWOYyByoZ2I49kH4yiu3wpcsBApHEoU+O7gTt/6az
         d6d9uhevd0PEtlNtHwvkUgBxzEamnH/Ju36broMziJVHw/JkfQVRlUzXUqqadDlIWUPO
         SKLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WvagHzfk;
       spf=pass (google.com: best guess record for domain of batv+a133233defd210c95f45+5736+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a133233defd210c95f45+5736+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w13si10517933pge.212.2019.05.08.09.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 08 May 2019 09:58:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a133233defd210c95f45+5736+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WvagHzfk;
       spf=pass (google.com: best guess record for domain of batv+a133233defd210c95f45+5736+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a133233defd210c95f45+5736+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=x2WuU/X5fa5tUVfwJobGS2HfWE2m292r4J/u47Wd82s=; b=WvagHzfkLT5uNstZZ33NzU8f4
	hVRF06AuCxJhAWvqiZKox4/2Nfevff1DInfGoORtzQW+kOTzEwOz2D0pN1WsVfq3c0szMFWAsntze
	flir9K6/Xz58geaWHO0lBGR8m/i0p8MjqeGp8pxnONpBNbMwqgXhj60gzgD/nNxjh1sUqYc7evbBi
	amGm5itevVi3gSAVbNmFKXK7tPwhMvTUfCrbQ99DOdeKj2WMEHulKQNkmG2v0IzJib2n4UwagtS2Q
	WJK03LVZfAXQ883EK+5tiBm397uUhr8ew+Rmmq5FzR7mmvyCV4pgMPI+POmu/zHUsi0bEK5DNuY7C
	chf1RE70Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOPtm-00039J-A2; Wed, 08 May 2019 16:58:30 +0000
Date: Wed, 8 May 2019 09:58:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 52/62] x86/mm: introduce common code for mem
 encryption
Message-ID: <20190508165830.GA11815@infradead.org>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-53-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-53-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:12PM +0300, Kirill A. Shutemov wrote:
> +EXPORT_SYMBOL_GPL(__mem_encrypt_dma_set);
> +
> +phys_addr_t __mem_encrypt_dma_clear(phys_addr_t paddr)
> +{
> +	if (sme_active())
> +		return __sme_clr(paddr);
> +
> +	return paddr & ~mktme_keyid_mask;
> +}
> +EXPORT_SYMBOL_GPL(__mem_encrypt_dma_clear);

In general nothing related to low-level dma address should ever
be exposed to modules.  What is your intended user for these two?

