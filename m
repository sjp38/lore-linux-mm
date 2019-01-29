Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FE5DC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:24:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A0F720869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:24:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A0F720869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE2428E0002; Tue, 29 Jan 2019 13:24:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E91CD8E0001; Tue, 29 Jan 2019 13:24:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D815C8E0002; Tue, 29 Jan 2019 13:24:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id B19718E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:24:34 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id s3so17349463iob.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:24:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=824iHOQ6ZVTZGDGOFtGGbG4bABFEft3RPBzbH2O99Bw=;
        b=ao+W6BJuUvRFpJgApbcgnCvDfhDdv9yjvuZwxNkXP1KjHiOVBlbfVFOkXHcNZNqX0d
         In3/rtug8M3UYHwKxh/+QzHLFPWTSUudG6JGjvI3Bevn/r7eTlvxFVl7pSFmCSle1vk1
         fHFsZfaT9AXqWxoQ+JuIE7c85H+bcx6cvE4aQVm2qx/DMOf/A6YhllJXtJ6KDzwbRa4j
         UFkzkLbCQiaxBhJTS/hkaRdlsVf9hnB9f/S49rk1/pHqtfiH1uEI1kmnqlhq8nuWzG8e
         md2jTGbxjJGG5k0wQ1mOVadwry00ksgzSSf2aQNDsk2+q4lkwwtcp222WZ7Azn4J/mQx
         LFzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAuYQyhcWnVY4WiWQtmY024uEcYKN/KA7CsnGhpe2/CsD5v+Zng0t
	ik7EXhrIrYX5h4+IA2LJEvv3UOUS8zRluG7aBW4vi9PkHFaF9cnY6sXdLccST2z/sGSbqyMlrOE
	SjnBqrt7Eryn63myvVXfFMiB0+FZd6z7fzJxDnlzrGXRmQa/Y06g0tcnThRWycOtUCA==
X-Received: by 2002:a24:81d4:: with SMTP id q203mr14873864itd.23.1548786274501;
        Tue, 29 Jan 2019 10:24:34 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5dVlHCEI97hqTVk8te3Ziq74j3WLIbkgO+bjfHg5l/G23P52XRDfQCExbphyKlUK694gWw
X-Received: by 2002:a24:81d4:: with SMTP id q203mr14873841itd.23.1548786273878;
        Tue, 29 Jan 2019 10:24:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786273; cv=none;
        d=google.com; s=arc-20160816;
        b=UMq155/JsT3lB5lv40IYLJkwWkKxXZMn27nOPVmGx8JzrF6btvxu33lXxDVwphtHvP
         7ccFuFKYJis7PT76+0Fy+AVVPI4g7qOFb2YNlqK+ekXSuxznJHXeBBl8oE9iWByUs4Io
         AWVfji54pGPF6kVqUl5N74mEhKh3J5vboHrUxVQcAcyMpYR6KBhVKPmAsfWCShodZ8e+
         18JXPyuJmJfLn/AAdWfhEa00LntwlVWjt7yNejaTscn4ZKzn725afMedz/QdzjxuhkYa
         doYLs5Ie4+S6ID693R5OkHMSBMdTdKcRrGavecSuVIcXyacBfOMb/l5tCNjTEGPyT+rU
         XE8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=824iHOQ6ZVTZGDGOFtGGbG4bABFEft3RPBzbH2O99Bw=;
        b=BSmxhqI/osXK71241lrrkPTpks7qUtiIHMTwCEGLQBf1j9DZpoinwewQX+D/6XkcP/
         S4+6C8AofaOhmTnD5ZhrWmrtCpcwW9fzXPaZvgBU20LjQVRzsbY6oKjsrI1sczs91lAT
         M5eWuEo1OFlv+jmtAOjqkYWGM3OwHK+lIWzH5zPa03Fk/dZ1TkYrwID7Virh3gs9/pcD
         ecVpUFaGdiXk/MYasWMILEOepg+shR7CSxY4CeS8mv4iQTGJCaLE3GWYKfj5r8FR9lLX
         c4xoA/uDsyBuIgXnhj23kJAFimd2FVYDjnGQTU+UX5ypqYo1BqMlxibeRqp+CuxpIiko
         RyNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id a16si1937970itc.15.2019.01.29.10.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 10:24:33 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goY3S-000521-OA; Tue, 29 Jan 2019 11:24:15 -0700
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>,
 linux-pci@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 iommu@lists.linux-foundation.org
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-2-jglisse@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <f66ba584-9c4a-f6cd-c647-9b32a93be807@deltatee.com>
Date: Tue, 29 Jan 2019 11:24:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129174728.6430-2-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, hch@lst.de, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, jgg@mellanox.com, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer
 capability
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> +bool pci_test_p2p(struct device *devA, struct device *devB)
> +{
> +	struct pci_dev *pciA, *pciB;
> +	bool ret;
> +	int tmp;
> +
> +	/*
> +	 * For now we only support PCIE peer to peer but other inter-connect
> +	 * can be added.
> +	 */
> +	pciA = find_parent_pci_dev(devA);
> +	pciB = find_parent_pci_dev(devB);
> +	if (pciA == NULL || pciB == NULL) {
> +		ret = false;
> +		goto out;
> +	}
> +
> +	tmp = upstream_bridge_distance(pciA, pciB, NULL);
> +	ret = tmp < 0 ? false : true;
> +
> +out:
> +	pci_dev_put(pciB);
> +	pci_dev_put(pciA);
> +	return false;
> +}
> +EXPORT_SYMBOL_GPL(pci_test_p2p);

This function only ever returns false....

Logan

