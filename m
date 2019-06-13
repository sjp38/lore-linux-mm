Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63236C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:22:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31DB22082C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:22:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31DB22082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B92966B000E; Thu, 13 Jun 2019 08:22:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B427E6B0266; Thu, 13 Jun 2019 08:22:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A30CD6B026A; Thu, 13 Jun 2019 08:22:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6853D6B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:22:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s7so30604020edb.19
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:22:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/l/UqAqZnFMeSJRnY7XsiijOnZhzthmvp1wjaEsbYDE=;
        b=JmWVmdGXYro9JRMbhlXgYe3JfG5o/bxJmv5KlmC9vd+xz6FBxptYSyZSViB/NElhyV
         7edIB8tKxuRuK/O7H6kKEKDWnsecSNcUfD5snp6MMDHvJluEQJGV+HAO++/YDbERLF7b
         LncGm8v7Usct6eoS2Gu5eUFIZGNgBjNIUPplEEMQoYyRKU/AElkN9yLPfTYFVABcwvGf
         bc9qSO4NJunK+cFFmt69QOoCszph2Huca9UBiSCvYR5rfJB8OlbGDSo1WUHlSF8zz2ux
         YZRjKsDMMDIOz/MZEbQayh7863DZgDEqzY6zPq5p7tcIjLSkuipExKEPFlxRGicSS6JE
         P/Ow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUUaumZ/NY3DNLjf3yQFe4qONnbXMi0iS44wqSpoBv6kioPt1AX
	4Zg/dKmPsHxHTDkk0/Ucv1yM/xtDlVosBbZmre3oWLvUt2Wba7JBZ6Na0oilTXEgmROSwTgZBBj
	v1wyo4Rdgk7KJMqiSFIgMZYhCWI9DBk4nd91LwfVUoQCkn//HXbj3HSN8BxBDEhUHpg==
X-Received: by 2002:a17:906:c459:: with SMTP id ck25mr32458954ejb.32.1560428571965;
        Thu, 13 Jun 2019 05:22:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKyRykMe2PTeCXrKKgRSnF3d88/oIainTl/CJotMBP20h0OZsunx6iTGR1SEau51W1pzrh
X-Received: by 2002:a17:906:c459:: with SMTP id ck25mr32458894ejb.32.1560428571168;
        Thu, 13 Jun 2019 05:22:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560428571; cv=none;
        d=google.com; s=arc-20160816;
        b=ztjmSrEEJWJ2Zl2qJPK9MfoYJXNmY9Il43mK7b/Ax6W2dreAmVGK99MgSmWfuVzODf
         nTbVhDIim1rU026CZYBijFVXmoi2B90nkfIaCswKrpojDRO15RiPpM7QyW6IBuHVXsL1
         C0qeQs6FXdJf6jAoZauHOdvSzTDtJm3uqME9TvK1k2I1HhXzvJc7btAk3aJjX1lc6ShP
         6rhAS9VzcmUVv9EwbXzPL7Xgdy03qu6uW5jYEDqmqBpndd+CYX1nBR8a80/NbqvTw0Bm
         oQBsSHSCBo4OTgfbcgcgM7coYhs3t2/LfDpoiUZgKE2KLfaXvrdII+7k/1EPYLOAXTR1
         ZMIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/l/UqAqZnFMeSJRnY7XsiijOnZhzthmvp1wjaEsbYDE=;
        b=beLD1NKKKELPJZtMekK06RFg0YDN239F4zI02RiExPUfr4AoHtK0SpJEzOtLDVFSra
         YZd0dWsg+jd8DhTGOA3KKwj6RM55b/oAGP4GqhPuzdxAx7YcCX7cg2/qZtJFw3KpvnSh
         KDNEVPxdPUfNKj2l7Q6nLcKcwYoUbum9Vkx4d1u3IZg5GehfmeFussGP45lduxbOpwf6
         SCLKX0Afpp8/zwpqsfmB2XzZ9HJlmENsNmAH8a2EPV0T8+pOr1n6/HIeukvnBbFmbgC8
         4A0B6Bu43ZBQaLNt7lE4hKe8QitWMIKVpQh1esiOyFb1y6okv5V/gV0CpyyJnJ+MP5/D
         YTjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g18si1864601eji.362.2019.06.13.05.22.50
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 05:22:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 42F202B;
	Thu, 13 Jun 2019 05:22:50 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 65EAC3F694;
	Thu, 13 Jun 2019 05:22:48 -0700 (PDT)
Date: Thu, 13 Jun 2019 13:22:43 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: =?iso-8859-1?Q?Andr=E9?= Almeida <andrealmeid@collabora.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel@collabora.com,
	akpm@linux-foundation.org
Subject: Re: [PATCH v2 1/2] mm: kmemleak: change error at _write when
 kmemleak is disabled
Message-ID: <20190613122243.GQ28951@C02TF0J2HF1T.local>
References: <20190612155231.19448-1-andrealmeid@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190612155231.19448-1-andrealmeid@collabora.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 12:52:30PM -0300, André Almeida wrote:
> According to POSIX, EBUSY means that the "device or resource is busy",
> and this can lead to people thinking that the file
> `/sys/kernel/debug/kmemleak/` is somehow locked or being used by other
> process. Change this error code to a more appropriate one.
> 
> Signed-off-by: André Almeida <andrealmeid@collabora.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

