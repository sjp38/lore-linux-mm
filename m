Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 661A0C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 17:38:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2650821905
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 17:38:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YwxIdAS6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2650821905
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B06FF6B0005; Wed, 24 Apr 2019 13:38:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7076B0006; Wed, 24 Apr 2019 13:38:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CC416B0007; Wed, 24 Apr 2019 13:38:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 630746B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:38:39 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id v16so12237274pfn.11
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:38:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8hZM1Gyf4fDZiJSnpLr+9CpjRwzMyoCa/eWpJcbkvns=;
        b=QGawxugjPxTMLK3bHKCf2PO5TBe60e9uk+iiN0D8K0LmyvLEcZnBBi4AErrn3LKeEP
         C2+6WCWkP5hKp9ncHXMKQV1VbinqhP6oMGxHixF4FOlrmRLRfMhj8wiSZdMgONQmWExw
         wu6PZohCCBbKKq5j7e3A0AKcz4/3Cpo/pWcdGuRf2OO/Rqw2lWwYzsNviy7CWQUiaC+b
         +kuIHT1+4txlKPdis9yzCpDADB0NODSPwJC0PBeJ2fnVYgolSTfdBbPp0njc4TrWA8KY
         yCilS4I5g4lQgV3r1xCsO28BwEYhVpMyWue23NB6MPKa2Mrm2YbTIyvr7+wOB/+duzHw
         GpRA==
X-Gm-Message-State: APjAAAVCymmU1ERZOq5g3nwa5r7jZ15HEphgnRnaeVaE13MmywxxjATL
	wKTih+ucaGAtgcj4fnOjGffKuMsaZ8ogsqi3/2/W1ZkC6HxKNHf5zwr42QyPrHGTihiWb98wXrV
	3n2nQdEmEcqOLcmM/r9d5wyEgFJiaUahxtSNNxvgidgasioIEGWJQuADLD+EpLR6ekw==
X-Received: by 2002:a63:3d4c:: with SMTP id k73mr31961348pga.154.1556127518836;
        Wed, 24 Apr 2019 10:38:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCXkVkOiE9bt3txB3K8kMyyVrAp9c//ngN4I+hdGRZVWkRan6kaYTn07rcUnRLy+dv4NZ7
X-Received: by 2002:a63:3d4c:: with SMTP id k73mr31961293pga.154.1556127518151;
        Wed, 24 Apr 2019 10:38:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556127518; cv=none;
        d=google.com; s=arc-20160816;
        b=NaJXlrtMC0st9XLjFn8IWNATesoW7txzvmZHcMyVaEEDhuYDjS/GUVJAi5MgRTqCFt
         60hFnWS6lU4UY9tE8ct644RySgMOXdD9zZsdxUyrcnqS40JOCMeOWOzH6JpFIhBkJmHG
         cVw0zMlpMmWWWdXUm0F6ofommhnYGpiZEVajD70dfxRKSidxZloFEgMmmpdAfGnchdAJ
         5tzeCojiaeO/p6qthY6iADHJSTIa/dqVJQrNAhM1wvS4btFMB/9o0+MANMt1Wxg73QdR
         HSHk6Fgw2/ZdU1dGPCLq5r/TbQlUgaZ9Whh3nUDg9koEeMukYIuoPID5WIuF+0hQ+HCK
         fUeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8hZM1Gyf4fDZiJSnpLr+9CpjRwzMyoCa/eWpJcbkvns=;
        b=XMlgisgtCMOzyUVuQVHyuh9iOtmCkn8G/wVbx5Cmu8K9Dig9kUFEbLmTthRCbY7kEC
         EP4iF8ZBB4gEtKQjLzYz4fo54aZ6LfFw0/UpOCcm0rEaRUC1x/tBc1VNwe7TBio2Fs2C
         id/teI4AsfZPkXEoz6li+U2nYZPtqMbq9DhM1Ct/AJpyiH99so3LkTqJ5rfSieZ8+b/G
         Gfcwdytjgj3E+hE5IrvB//KBJgJrvtYdyNQegpfjedd2txq38CesIlkAnNQiSBcXT3t1
         MjFsRjVTw9jRKbWK43GL0V1sJNES4xw2P62NMzt1nKSKANphLN+tI0BWdTfHdvRBxLCa
         8RKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YwxIdAS6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 10si10737737pgp.481.2019.04.24.10.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 10:38:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YwxIdAS6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8hZM1Gyf4fDZiJSnpLr+9CpjRwzMyoCa/eWpJcbkvns=; b=YwxIdAS6731khu9kCiWmVeXp9
	YMEoAWYnT+jclFuTNRz2pTKEKNlbkri73h+mWY8XpclIyfYlVjg2Qczu6BnTrU4Ku4ZyKRadtG6oz
	wJ5G3t1gg1/wu6HAnGvXogj8xkFRkXVZtv+veGxkJ4sTcOYGfIPl/CYCBs3cxEdfuuSN29W9Tql1C
	zKu+4GeIwlaG9cmZbVQUExBdeAIwTRUf5hb92A4GjAuiGwVe46hE/dGt43LaABAX85fOwruFZUjHs
	vw/lvsiTZ7sM+e5N94GLmEnhMbaECyyeLF/aI7NAGOwGV7qKIl7P37glxB8eiseLwwwx3BTglF+ll
	XTmsYLzvg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJLqr-00018Z-F3; Wed, 24 Apr 2019 17:38:33 +0000
Date: Wed, 24 Apr 2019 10:38:33 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux MM <linux-mm@kvack.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	stable <stable@vger.kernel.org>,
	Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by
 insert_pfn_pmd()
Message-ID: <20190424173833.GE19031@bombadil.infradead.org>
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 10:13:15AM -0700, Dan Williams wrote:
> I think unaligned addresses have always been passed to
> vmf_insert_pfn_pmd(), but nothing cared until this patch. I *think*
> the only change needed is the following, thoughts?
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index ca0671d55aa6..82aee9a87efa 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1560,7 +1560,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct
> vm_fault *vmf, pfn_t *pfnp,
>                 }
> 
>                 trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
> -               result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
> +               result = vmf_insert_pfn_pmd(vma, pmd_addr, vmf->pmd, pfn,
>                                             write);

We also call vmf_insert_pfn_pmd() in dax_insert_pfn_mkwrite() -- does
that need to change too?

