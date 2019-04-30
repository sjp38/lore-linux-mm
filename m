Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EAA8C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 12:34:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51F0F2080C
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 12:34:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51F0F2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAB1E6B0008; Tue, 30 Apr 2019 08:34:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5C836B000A; Tue, 30 Apr 2019 08:34:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4B3D6B000C; Tue, 30 Apr 2019 08:34:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF6076B0008
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:34:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l74so8972906pfb.23
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:34:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=5k1BDEBL8dRvgNYBfltCbHPbHJzcVqSyMC2Pcqnjm/4=;
        b=ENUeGXJxUNonIL2RBfZ+kYPYL6hKOiZIkg034oT+r7uocT03wZ2ZIJDG8xLTtJAf25
         PC/AMHOKLaa0pVu4IMri5uoe8jRh+lTBHkK5avkGiL4ulm1HO9ACp26V4QoR3/wyi9Qb
         obuRNE5ZSwLkMk4sWRhvyk9HHKAXdnC1M72kniK9oQhzvzhaxCx92M20ZBYABRou0ooz
         Us8NBwq6WFOgpG+UvfHmo4l1fbb+7rf31ih3uDiaaDoKJ8sVTfO1eMqwGySQ0K1VIkG8
         O9b7Hd/MO77NA94Bj+VODVs9eAiqNREW3E0gmv7uppO4KAYAgdnZHA5qhLjDkE1JM0D7
         KihQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAVKtq4w2822x8KUtk32p+IKodlJp4ZJK/tZGRBTfqbzJtTUJvhQ
	e08xg3p8g1kytm3t3Z1Cc4KbaArVzSEffqnS/pw+q6c+h27e/ttqDJK/SjfRWDmdPgm6X3O2vBZ
	rYp56nFEnLcBeZWTuPfHsnVnnCITsgMZ2durZu7pwNlphTAYTxOd+2DIqZV87IvCIHA==
X-Received: by 2002:a17:902:e48b:: with SMTP id cj11mr26005387plb.223.1556627678413;
        Tue, 30 Apr 2019 05:34:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxL0aPf5tQwME4aodxeMKyJmOr7M96ySISEE1hw6OM3gULqJ/WPQqDQG87hSxHOFTmcnGt+
X-Received: by 2002:a17:902:e48b:: with SMTP id cj11mr26005303plb.223.1556627677533;
        Tue, 30 Apr 2019 05:34:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556627677; cv=none;
        d=google.com; s=arc-20160816;
        b=GqXVXwZ01DabeJ2NlWnQm0KHZ0b50/W8Hy5Wp68OJ3NoqEMz65+gJe4KLTxJ3HdGqt
         q8jkgF1eeLcB9spFrMjcPFmwW8zl4iiKO/eJ2wozOn1ckEZECtC/09DRJa9xkyydLV/7
         jff7LDOWZ77+dETnRpCZB4DEnpAot4QBjQJTOaNPXH0aJR1u0j84D0GYHxP0IoskSwS/
         9mkEU1JlYuzYzvLpLPXtnCTEbXCt1F89JrnjljPulvAW4xanMz99AtCaMPRoxBozSiED
         9w8CInpohYIonmVAp2NB1BWaX3V3DeaNI6bRDEQxau2/L/ilXybRlp/c0tGTsL9v0CV0
         YQ/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=5k1BDEBL8dRvgNYBfltCbHPbHJzcVqSyMC2Pcqnjm/4=;
        b=pOtBBgCKj9Sn5kkckHyqMr85CkSr2M6OxuWchKQWJJxAzyR5zeupdFjwp4NUIDcU2q
         xOHzbgoqoldQEbteXQcbuG0GdrFdkj7tV5i/of9gQmhYVsxUx6/VOJEncCtKHr5wNU+T
         i8U5E337+HHQ0oFTrmNTLlSCGW1S+KN/qYX3s8feZ3/bM+Q2JqAjsTgYt2lQW9REja5u
         5phaEMiphD8pr+KG7jSMrW/nabzgJATEDVvrIftHxZDoCm9WueobdT2Z1icteOGOsq6e
         PZ14lVKmwfb4SC08ai2UMnljfp9wz34b2InDC5CEKl4LVT635uh+btKj61QKqrcrSnPq
         5iSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id e36si35928486pgm.89.2019.04.30.05.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 05:34:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from localhost.localdomain (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id D7C11891;
	Tue, 30 Apr 2019 12:34:35 +0000 (UTC)
Date: Tue, 30 Apr 2019 06:34:33 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: <rcampbell@nvidia.com>
Cc: <linux-mm@kvack.org>, <linux-doc@vger.kernel.org>, Randy Dunlap
 <rdunlap@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike
 Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] docs/vm: Minor editorial changes in the THP and
 hugetlbfs
Message-ID: <20190430063433.262783fb@lwn.net>
In-Reply-To: <20190426180429.18098-1-rcampbell@nvidia.com>
References: <20190426180429.18098-1-rcampbell@nvidia.com>
Organization: LWN.net
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Apr 2019 11:04:29 -0700
<rcampbell@nvidia.com> wrote:

> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> Some minor wording changes and typo corrections.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Acked-by: Randy Dunlap <rdunlap@infradead.org>
> Acked-by: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>

Applied, thanks.

jon

