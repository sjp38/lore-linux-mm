Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EED42C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:50:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8C75218A5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:50:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8C75218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A70F6B0010; Fri, 29 Mar 2019 13:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52D856B0269; Fri, 29 Mar 2019 13:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CFF86B026A; Fri, 29 Mar 2019 13:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 170806B0010
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:50:28 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id a188so2496379qkf.0
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:50:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=jUF3KgmYeni2oaq/7GqeO2T5xqbLj6M5hpE5lsKO8+g=;
        b=cxtaZzqZejc2G2vmNu7SRbhr0NifKVY2H31N9qfBlPrlXFros4O/wQuET31QhZIMpG
         POVuDEkF2YVrrGPirh0XFHLiTqT4dxo4iMtfoLQ7XZvUwfNMAv+ciqqcF2NWEl6xr5d/
         9aKYOpDt59gfzLoyQaAACuOAJLOPlsGfvodoZkhuwLq8ryWNEycJAGRF5QYUFqZe0PaF
         EYc2wCbpyodzrzYisUI1boXtYrRx2/6eb9qGL9AzpElUz8smvdJFl1NkqBvvaQ9Lj103
         1j99AibjfUsyvCLMeq3kYBedQI/RkDYzBpxiOo0LOcVhIyt08RRK2huB1dLvxPVlj5Ip
         Dbjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAUeRTSYQx7VV8M9EXJlw0hGMM0/G8Ywslv3MCfMNyKo2m98908H
	0Yot+hkcBt23D/mm/CO4eyr3whkhermvg2RLAWzY1OYa4IjaTKfn+oCE61LP7abWDY2VtDoQNk1
	ARPnvhGM3NAtt3dD/pH+YtZYOEgGd/Q7OEMk1GW7EtAQWJd7FgxTWAExU+UeggcqsgA==
X-Received: by 2002:aed:23ac:: with SMTP id j41mr3236582qtc.181.1553881827861;
        Fri, 29 Mar 2019 10:50:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBMUolga6owJh/Z2MVonHAHSk1d3kPkjZKIqPaPVCcMszypKKFrPQKKF8/c1Fu4Mdv6c2b
X-Received: by 2002:aed:23ac:: with SMTP id j41mr3236530qtc.181.1553881827231;
        Fri, 29 Mar 2019 10:50:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553881827; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+oWBxcvxK6y6rNVfWTRENsJ2t2r9IpiJVuyklTVgAsJ0duyR8gZ1JXhJwRUYE6Plf
         DwLEDHQo+PLnmCdA5Fq4ylHST4+2/z0mPxci4l/kQTws0uCVd6yU4Ns88OmDkz1dCNcr
         ouGfjSW6BcX9NYl3DPmJS/YcbpmeND9THBJdK9bbGjgzu0rGwbZM9yREpISty/0jPX2+
         FZcl7uynb73ivVnUSxh72Z/BUhAvfBBajNl9ic2R1IcaN0df5SbZUgC6lmsU5haBbzZ9
         LeoVXDpIRryU89eu+vpH7DjK5aQIseI5luOyPd/fRvL6HFPMRTK90gWyFE46fEiLiQnt
         ofpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=jUF3KgmYeni2oaq/7GqeO2T5xqbLj6M5hpE5lsKO8+g=;
        b=cZzWmV2kGZSUpQDA+m19askIFVnfOydAiWMxMz2WmtV7eejhDJYaLK08b3Dn95QMCh
         6f23os7YjYDwnx8sdfsKChqP9T7AOBkRxCQW3Rla557EFR8i90Jw5XdzunNVuW3P2pgm
         FgV944ZkZEi8RM5GNpRFywj/tCNDNZn608Fl3qWHAoIdLs4nOGp8BKkarYdNnBjgeO5+
         mBto5meMLZsFicF0g3gvmDeeeiEQElAq0qjOlM4VcbfzbPjnUScsg2WVGpk9MdxFZBb4
         7IaFhn1wmZT4tsR8dSlA4squgWMppbckcDMO+jpPKDdXYyGCHewUpNx9pocZv3Asn494
         OeaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id f16si1522986qve.57.2019.03.29.10.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 10:50:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1h9ve4-0000x0-Cd; Fri, 29 Mar 2019 11:50:25 -0600
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>,
 linux-mm@kvack.org, linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
References: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155387327020.2443841.6446837127378298192.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <cfda881b-d99c-7c53-64cb-745ff4b257b0@deltatee.com>
Date: Fri, 29 Mar 2019 11:50:23 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <155387327020.2443841.6446837127378298192.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, bhelgaas@google.com, akpm@linux-foundation.org, dan.j.williams@intel.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH 5/6] pci/p2pdma: Track pgmap references per resource, not
 globally
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Dan, this is great. I think the changes in this series are
cleaner and more understandable than the patch set I had sent earlier.

However, I found a couple minor issues with this patch:

On 2019-03-29 9:27 a.m., Dan Williams wrote:
>  static void pci_p2pdma_release(void *data)
>  {
>  	struct pci_dev *pdev = data;
> @@ -103,12 +110,12 @@ static void pci_p2pdma_release(void *data)
>  	if (!pdev->p2pdma)
>  		return;
>  
> -	wait_for_completion(&pdev->p2pdma->devmap_ref_done);
> -	percpu_ref_exit(&pdev->p2pdma->devmap_ref);
> +	/* Flush and disable pci_alloc_p2p_mem() */
> +	pdev->p2pdma = NULL;
> +	synchronize_rcu();
>  
>  	gen_pool_destroy(pdev->p2pdma->pool);

I missed this on my initial review, but it became obvious when I tried
to test the series: this is a NULL dereference seeing pdev->p2pdma was
set to NULL a few lines up.

When I fix this by storing p2pdma in a local variable, the patch set
works and never seems to crash when I hot remove p2pdma memory.

>  void *pci_alloc_p2pmem(struct pci_dev *pdev, size_t size)
>  {
> -	void *ret;
> +	void *ret = NULL;
> +	struct percpu_ref *ref;
>  
> +	rcu_read_lock();
>  	if (unlikely(!pdev->p2pdma))
> -		return NULL;

Using RCU here makes sense to me, however I expect we should be using
the proper rcu_assign_pointer(), rcu_dereference() and __rcu tag with
pdev->p2pdma. If only to better document what's being protected with the
new RCU calls.

Logan

