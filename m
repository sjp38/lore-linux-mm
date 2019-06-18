Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CDE4C46477
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:26:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54E182085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:26:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="R6ur39y7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54E182085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F39908E0006; Tue, 18 Jun 2019 00:26:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEAE58E0001; Tue, 18 Jun 2019 00:26:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD9198E0006; Tue, 18 Jun 2019 00:26:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5D588E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 00:26:08 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a5so7094794pla.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:26:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=L4HcxDuuNAoD4D5yeHroWYczHTL+R16auCPmQfIRMQY=;
        b=RKTsbiDSKqAfdM33KiC+UJJw4QRmFvm0M4zoUvXnU2UaWVRtnhOKy8NKbilNNbyZ4u
         qWnfPV/Y748ssEGFwEiAqzcr5Vivz+a39/7460RDynD0mjVZ4mLx5TNqHaCAMq5ZzdKD
         OQhILGHiQrEPXUO0VQSSKZcmk2KfgmvXmO+eOUmkKcitaq9qrc14nPQ1VwKz6J+EcqhA
         RG2UJvaiK5oKhrHXbv+27NBj2dTTdyBwRIJK8Ptpwu/IUV6lBxYzUfN95KHmaRNzwK9b
         a3aeSaez4hpBT4M90aB0sYcO6SIUeMnJGYoMr/SeE3Qiy1wa4ah4jVTOfUXeoYt+wV7Q
         bTdA==
X-Gm-Message-State: APjAAAUBqM5KKDDD/TlRp2OUNtYjsf/Ui0efSuW4bVItKcY6w167BA+9
	zrP7M2dQWgcKMlteF+zg017P2Zat4lNowgvvhDRkvRsZS8SDRDk8F0yH96gMCOIftwzfeMr+JsC
	6O/z8GyL7hjYtmTB0HRDN20WjZKTSmADEMF8MF3tBMrryFt2JMOpWYTnNTXxO4QIpAQ==
X-Received: by 2002:a63:4d05:: with SMTP id a5mr713453pgb.19.1560831968067;
        Mon, 17 Jun 2019 21:26:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSMawt4aTKVcn2JOHHBsICMcchzp9YXz+TrQ3zHT+/g8hCLAN8Cviqi+J6cJsA6MNXv0Ez
X-Received: by 2002:a63:4d05:: with SMTP id a5mr713425pgb.19.1560831967348;
        Mon, 17 Jun 2019 21:26:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560831967; cv=none;
        d=google.com; s=arc-20160816;
        b=PAGsc3S6KkKJCxZFDpykq+iIwfgvZsUvszGJOO0Hsnl9Flcg4PmMMB7nAvUeVHO0U2
         +MtXqTfWeD8KQxCpLAjXhLXOpY3s5TkKJiOgHrSLkpRxx02a+mIvi8xJ44LgDiaXB1+e
         28LVoSHnuAKPq6jsZsIoDQKEgiAO9IaxHsllq/wOcKGov5ENDuP9Oehjcp9enSdZh8Ut
         39g1Ght318XO09rawaMgNp6WPOkH01H5PzaM62OCYi5aGUwscLnmaWByZ/HB0xxig4Z0
         Pvw3ZNe45DTKYI39c1GF3DZw4F/GOHXCdlhGBusy/haT/+wO6dnPc96K1vLMeXA8QBPM
         TRQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=L4HcxDuuNAoD4D5yeHroWYczHTL+R16auCPmQfIRMQY=;
        b=IT4zzrEor2p/oxbewA/9evxAucKHkV5S3vXsbMngklHBDbYnmfHPxnlGoc8KjkKkyB
         f7Eg8nUy6Q2lG74CWMv6hdu6p+CqQR3o++sJdZr+keAHIHUrhtm+YyuXuygSBoP3ZzTa
         GSxx7fUDxQ2Dh1JOEBR2ElpOUSUit+E8bQyvYIkWl6O2e924G1AmrCQvExKryH1Tntpc
         NGrSurV431BcMrRmgPIju5y/PFDueXaxOb/+IPPwZV1mOhir3EZZZ5D1xdIBont/q+fK
         xGhtqCLgwks1KUN6hkv7aRQKRW0h+5ine/kkbNiIaDHYN4aJJUnBexzO132RkvZ1vHo2
         htYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=R6ur39y7;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y11si11856288plr.381.2019.06.17.21.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 21:26:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=R6ur39y7;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 854072084D;
	Tue, 18 Jun 2019 04:26:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560831967;
	bh=xv/fCdFQ6SfbaJzNr+4Vp5gITAmLP6lf4CXGPgHSad8=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=R6ur39y7TUbCZ9I9GPNBpsgEq0A7kXynJU20VbzOQGtqant4HGaLMKo1/Qfhk7cr7
	 tde33KHi5Y7TxhTaqqC6+HziktP/p9+akYAS8ke5AZ3GOrAwOuR0iaD1yngtP6A7Zt
	 xKHocsz345eJckm197hPRlWYwLgBSR8v5C1arUzU=
Date: Mon, 17 Jun 2019 21:26:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 stable@vger.kernel.org, Borislav Petkov <bp@suse.de>, Toshi Kani
 <toshi.kani@hpe.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen
 <dave.hansen@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>,
 Bjorn Helgaas <bhelgaas@google.com>, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/3] resource: Fix locking in find_next_iomem_res()
Message-Id: <20190617212605.bb8cc4571ee67879033e1bc4@linux-foundation.org>
In-Reply-To: <20190613045903.4922-2-namit@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
	<20190613045903.4922-2-namit@vmware.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jun 2019 21:59:01 -0700 Nadav Amit <namit@vmware.com> wrote:

> Since resources can be removed, locking should ensure that the resource
> is not removed while accessing it. However, find_next_iomem_res() does
> not hold the lock while copying the data of the resource.

Looks right to me.

> Keep holding the lock while the data is copied. While at it, change the
> return value to a more informative value. It is disregarded by the
> callers.

The kerneldoc needs a resync:

--- a/kernel/resource.c~resource-fix-locking-in-find_next_iomem_res-fix
+++ a/kernel/resource.c
@@ -326,7 +326,7 @@ EXPORT_SYMBOL(release_resource);
  *
  * If a resource is found, returns 0 and @*res is overwritten with the part
  * of the resource that's within [@start..@end]; if none is found, returns
- * -1 or -EINVAL for other invalid parameters.
+ * -ENODEV.  Returns -EINVAL for invalid parameters.
  *
  * This function walks the whole tree and not just first level children
  * unless @first_lvl is true.
_

