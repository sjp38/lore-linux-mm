Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90AAFC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 22:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5141520823
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 22:04:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5141520823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E01068E00A1; Tue,  5 Feb 2019 17:04:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D89268E009C; Tue,  5 Feb 2019 17:04:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C53BA8E00A1; Tue,  5 Feb 2019 17:04:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 831F58E009C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 17:04:18 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j8so3401655plb.1
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 14:04:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/v1pskoyWlIgJsKIS1qrr0fFi5+DWz4ORWHdmM26shA=;
        b=jjirQs11YzRm9fbHX4SJoVPO0IvaAcXFQB2JBlvDmKeweaKvC7cSz7gYKscNjU+ODg
         3nm8ujUweiaLQcsavJsB+kwRCoHGCUSuoLg+w29kEYJ2Ng0s2UDrmDUa5swOxGcKDH5s
         aaTZEERwPhpEqpdD0zz0VQO0N+wULpCRebwWOv8N+TJClLXVL9BB5/3Y/Gp7j7g8v55e
         53xc2IQNww8GXkpD8dJiKMSAnpE38QNkwTdeWd0VY3yTP1/oY2qrV3t3xF8o6tNfpjTA
         qE9X+WH6KGZk3yGYEt1sEd0pIFlyv0eUEdQG748MnD5PPZdxCiU2HFkqERKrPmfD17HO
         ceew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZCIbu/4g1HqpxNuZKINdbMEKRUlWCDqBMkyAh1OgJfRKW3MmHG
	a6rFZwn5Sj7GO1wAsb/W8pW+BLv79ap3IZvBH9strlgrLGtdwCr9Euqc5mjVvCBcbCo+ka6qeaf
	SItUYE8Wav599jKuj6FmH609L0z2NDi56J2A2+uqs3QZ2hwSW/CAzkqRspSUwafWalw==
X-Received: by 2002:a17:902:e08b:: with SMTP id cb11mr7388421plb.263.1549404258109;
        Tue, 05 Feb 2019 14:04:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZNExIZUiP60AsW+AcNKbGsYaF6w1J9ZcQN4yc62e7E0+wPL3cTNCYUq8DyC5A+bVHQ/DMe
X-Received: by 2002:a17:902:e08b:: with SMTP id cb11mr7388365plb.263.1549404257425;
        Tue, 05 Feb 2019 14:04:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549404257; cv=none;
        d=google.com; s=arc-20160816;
        b=PbiqGSF6zd2Ab6+jPA5WMeykC542F7w31jw5jgocmbc6CgKMD4YlfcZwfdDj9/KTj+
         EP7CJ9Hsv3ctghuOO9OcEg9+Tbzm7KVC6klGnewFd9FNi3LC94bjVDvRGKw6QL+R4S6M
         9dyI/TNLCibVo5d96r84lEUMOcZsBXnODPMqxl4fdEZK6Pi1fqdXIX9/STik/fIdj3LZ
         eppkwkXg5/15dp/9LdQEP+HgVwzJzYZwFrf1C2KBMM2walMkf0A4/QcjAORl4mQdIyqZ
         8ETaRU0Fta1IGaVK/7vyVuhnQ4HuAH1oJeElGFPtCYZola0AVuHbMH9fIpvNnLpEy3ca
         h7ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=/v1pskoyWlIgJsKIS1qrr0fFi5+DWz4ORWHdmM26shA=;
        b=XjTYaoqKgK3AKMVWVrxv+FiFOwhzJcl4tFEyRFS/1P6tlyVVBS6SSnQuSAvoVuvRlQ
         SbEiuxQxK1H+OMIvqURozslm02i8UXbVapkvqMVebABxpCm83uhfcQOoyk/EPKh7FKms
         E01qd1jltQ4AI+mEHQFE3JwLFvcSk2/vYChr+BiRMq7dGhk2e0VyURwk+CaRLWPa45Fa
         EBMvv4LHx8f6QSzHD1LRiR/ECZtQKOJMF2b6NxO7kewJjHTmnIg6bw07ucJUHZ/uijj4
         ZD9y2k6FZ5sRJn+s5mkymMk7+n5Dl5RCs1pcpSuGngq75Nx//U0pCvQiNpSruTulkjwP
         Wqow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c32si4354786plj.38.2019.02.05.14.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 14:04:17 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id D0F2CA840;
	Tue,  5 Feb 2019 22:04:16 +0000 (UTC)
Date: Tue, 5 Feb 2019 14:04:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko
 <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, keith.busch@intel.com
Subject: Re: [PATCH v10 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
Message-Id: <20190205140415.544ae2876ee44e6edb8ca743@linux-foundation.org>
In-Reply-To: <154899811738.3165233.12325692939590944259.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
	<154899811738.3165233.12325692939590944259.stgit@dwillia2-desk3.amr.corp.intel.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019 21:15:17 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> +config SHUFFLE_PAGE_ALLOCATOR
> +	bool "Page allocator randomization"
> +	default SLAB_FREELIST_RANDOM && ACPI_NUMA
> +	help

SLAB_FREELIST_RANDOM is default n, so this patchset won't get much
runtime testing.

How about you cook up a (-mm only) patch which makes the kernel default
to SLAB_FREELIST_RANDOM=y, SHUFFLE_PAGE_ALLOCATOR=y (or whatever) to
ensure we get a decent amount of runtime testing?  Then I can hold that
in -mm (and -next) until we get bored of it?

