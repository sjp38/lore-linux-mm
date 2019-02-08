Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 212C8C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:01:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D78E62147C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:01:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D78E62147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CE378E0076; Fri,  8 Feb 2019 00:01:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67CC38E0002; Fri,  8 Feb 2019 00:01:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56DBB8E0076; Fri,  8 Feb 2019 00:01:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 240378E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 00:01:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p20so1576428plr.22
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 21:01:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6DtH5GzDa/BORUyi58vTNIMeMmvu8TwrEq0LEl2CNX8=;
        b=egXX0on/Xi4dBOhUNCYICNhlnVwIMtL0nyYXB3wWQpFK7YS0faqNgd8aWkDbbm3EyQ
         Dr1qyESFB7X9kUOtlHxptWhddrdj7fxAZI5tr/jbFbbvgMEp2gnpi76c5x+CjWz+TcNr
         Tsrgs7qerUllXL/X3V5PVvjzXfUwwqb0fnz8ybYzMMp8ONB7MxK7sOzci/A9pK3uaw9z
         sVtW5wQijczTMShXObsxFY36UuFGouQWxX9p+jp4WU75O6uMI3FqLbYgs5E7wO7cMS62
         4ySoUsiTNEMaGSVH8cicQZ1//z8Ji00wCiyGXq6MLAV7t18vUDlDVC2g1w3C1oRayZ07
         crcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuagZ3td1NErQNZTJ8eYM1XINL00EE0+f4j/5vK3x2z4qo1ZRF23
	CxsHeqYDURSTKReGzuGLHFAE/+ue7v7WNON/FA3Ymeea79T8qAH1niagb0sr9AP66tHlD24laLY
	uvPf+v1Lnp/o/2fKZ2vbDH6WknXQ1wiKNH9/Sj+rHfrgYP+oG7muzVM7MNkoinKh8QA==
X-Received: by 2002:a17:902:684:: with SMTP id 4mr20500744plh.3.1549602103763;
        Thu, 07 Feb 2019 21:01:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQEQi5gczHcmDw7fYVAXV21XrfnG0jkfIzMtOgd64ylPYjli7DAkDlD6IIRuM75BAZfKMt
X-Received: by 2002:a17:902:684:: with SMTP id 4mr20500680plh.3.1549602103063;
        Thu, 07 Feb 2019 21:01:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549602103; cv=none;
        d=google.com; s=arc-20160816;
        b=b28DdIuojOWn1G9FBMFoFikpqISEqFmTZaGnOg+RBlGq8tnwlxzBWze5PqvsElyLY+
         VUn7/nRAxmpUVWkw4aD8CI6DYb/M1BUUJW3kUVVDJPZjJBFvNJGD6Tw05+JcUxClvl1n
         DOig39Yq1Gfc8XyI/QB5j4xZV3twhttdFM6TgLADHqUVOLlFZN89hfIy2+N3YueIzgdB
         hl0Pb9r4W1DxJuKkm1/Yu45EsnDtQVybyy7C1biE7htSh7I+2oy+fhUYSmWB/LQUSpcX
         +eLcd+qvS+XEOwFKeD98u3NfZEhtq4epxaqYTTcL5In4qMvvFZlQflQ/prWHRReMt1Y2
         tpGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=6DtH5GzDa/BORUyi58vTNIMeMmvu8TwrEq0LEl2CNX8=;
        b=fNuvx/PQ4Rs/fUcAagHS2w31asfEM3hB7Een8Lasgwy28mbnM8A+R6W9tXkrwEsMQa
         cBSeKu8J/KLRmuiNtdf2BFNw7y9M4yV0hsyMUyE0fKri3OoX2KXhPgAbflsyVUOZ/C+M
         9OMY21DEf+oP+rUbCEdmK5R4i3nAggSF/D1eyFTwe6cgn7HgZVppy20JYLH07V37uUXf
         PBWYEE8NaEpO9aA9w+k+aT6ENqEUPatMtmiyjkuV4LZ5b5/9PjdW7+AiairLKqGg00Os
         cMMyjdl20WuWlix+ok9Oy4lKwtrEy7DvTymSKiEs8Y5yJi+W9j+dtJGpzXgM69RNDZe4
         8Y4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 33si1239843plh.245.2019.02.07.21.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 21:01:43 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 79C49BD47;
	Fri,  8 Feb 2019 05:01:42 +0000 (UTC)
Date: Thu, 7 Feb 2019 21:01:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org, linux-mm@kvack.org,
 Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm/page_poison: update comment after code moved
Message-Id: <20190207210141.f0c0b08841f53ba4ee668440@linux-foundation.org>
In-Reply-To: <20190207191113.14039-1-mst@redhat.com>
References: <20190207191113.14039-1-mst@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Feb 2019 14:11:16 -0500 "Michael S. Tsirkin" <mst@redhat.com> wrote:

> mm/debug-pagealloc.c is no more, so of course header now needs to be
> updated. This seems like something checkpatch should be
> able to catch - worth looking into?
> 
> Cc: trivial@kernel.org
> Cc: linux-mm@kvack.org
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: akpm@linux-foundation.org
> Fixes: 8823b1dbc05f ("mm/page_poison.c: enable PAGE_POISONING as a separate option")

Please send along a signed-off-by: for this.

