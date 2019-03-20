Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BAD4C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 22:16:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61599218C3
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 22:16:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61599218C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E270E6B0003; Wed, 20 Mar 2019 18:16:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD7076B0006; Wed, 20 Mar 2019 18:16:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC42E6B0007; Wed, 20 Mar 2019 18:16:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFC56B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 18:16:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f1so3973815pgv.12
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:16:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=M4h3uxY9mLN6LRL9SlAvP9Wuzq58G0qNJCL+78lrHpU=;
        b=JMdnTlQdE2iF6yaceuadLAUcKf5lnUCNwdIaMAbPcA4P0zkgJcXhU3gNdTOMNH+Zoi
         n7TitHEJnxAJvnoAkxw27qFQ4xEFKD/d1mqE0nITSwR+oUe4AY0/ZukYW7grB8JcxzIs
         BRl+6Cag4YApI2BNifxdXDtLd8gEbwYPIl7VMcrPL63VNoAMl3oC+hfN5YLQHkYmmlRU
         Hlg/jT/8g2pBOGG40l8dj7QdAjGKeGlOJBFImR81LNe6/r6yU8O+iJ26dvCtT0wk0t63
         IiDoBUz5omOvUh5SjmJF4WWgW/31e+JUEmJ6b4oRLWSeUtB/nkQgiSN+XVV0cd9PROQL
         3/WA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXh9h4GGj7xTTjl1RAsaWFk1z49vi7I9mCQjSn/MQnFUgEtXo4Q
	LE3a5yu6cP1f8uPO0CuryIH705MC/JcmDXlnLSgmO99T4JpyUMNV6KFwfqoDTfMsqSV7v87LCjt
	U18Vb1oVRbyvk3z5rx1LqEobvexWg3h7mEu3pGN9aC1/qMbUuSARp3TRxZELdsnkogw==
X-Received: by 2002:a63:8548:: with SMTP id u69mr272245pgd.85.1553120193217;
        Wed, 20 Mar 2019 15:16:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsFG6eumJPq49bmNnEHQlJ4qqDNzDxlo3I6tkbpZCol2pNgFr0w2fifZoP6pC44ySwQM7F
X-Received: by 2002:a63:8548:: with SMTP id u69mr272176pgd.85.1553120192231;
        Wed, 20 Mar 2019 15:16:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553120192; cv=none;
        d=google.com; s=arc-20160816;
        b=ekcf5MVj/2I+GSS5ApNl/wwfXMJMoqXlSlUe4TYPc8W8dN/L5mEHbGJz/adWy8YZau
         1gnk6CAj7aPwnUTfdrInfySfSSK+hgIQYf/tsGCmRjwf4uVKfw2dcRr4CplZvFU0/21N
         GLC6W9YNiMY9IraZ3p70GQLUgN9Oc26Ai2o+Xmp6MVSXZdgXfsqWVgyTjGSaf4ELVAjj
         woYUfp8BnQl2aEEkSol+6xrVdpl5QbkDKB0BkZzNgSHsv5HZkOSaxpGIZrqW1qmjLgso
         vtB7PSBD5P9pTS9SzRZuCmvLXVm5SybPxMm42z1+9Wh6DPAGKV89UBwB6JDXoP/lAbEE
         2e9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=M4h3uxY9mLN6LRL9SlAvP9Wuzq58G0qNJCL+78lrHpU=;
        b=eg5mR2VlX50RTqxFmOUnD9pBwRvc7IKHE9z4hYwKYlMyUx7lQHFoubU+Quyag9OBzH
         Id2YvRUSoN6kHxKRsFamMjNUqQa2VgXCpJ1UK6u9LrxlAuHWv9A4sVK5qaPIqOVynjzs
         amVphMgkiQxg9BrjWQ9jBT0B2Tv4al+mRkZ32GgPS+Tq8DwR8bkSsQN+5DEv2J9mhffk
         A9xz4RKJSIOXu2Z+649EsLnordGe3ZE3Vr9aJmzlQN7zT4MuAat5mwNS5AMtWf/NXKbN
         ySS390wrCYZUp4G9myCFMudIanv2CwSEoayl032VhJ+5I29E+5d8ciRpToLgWBDpWm8U
         Vu+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f35si2932230plh.152.2019.03.20.15.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 15:16:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 90ADA7056;
	Wed, 20 Mar 2019 22:16:31 +0000 (UTC)
Date: Wed, 20 Mar 2019 15:16:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, chrubis@suse.cz, Vlastimil Babka
 <vbabka@suse.cz>, kirill@shutemov.name, osalvador@suse.de,
 stable@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when
 MPOL_MF_STRICT is specified
Message-Id: <20190320151630.9c7c604a96f0a892c29befdc@linux-foundation.org>
In-Reply-To: <CAFqt6zbqYyzVB3HbYXv19jo8=3hGC=XZAkwvE8PCVdLOKTeG1g@mail.gmail.com>
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
	<CAFqt6zbqYyzVB3HbYXv19jo8=3hGC=XZAkwvE8PCVdLOKTeG1g@mail.gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019 11:23:03 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:

> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -447,6 +447,13 @@ static inline bool queue_pages_required(struct page *page,
> >         return node_isset(nid, *qp->nmask) == !(flags & MPOL_MF_INVERT);
> >  }
> >
> > +/*
> > + * The queue_pages_pmd() may have three kind of return value.
> > + * 1 - pages are placed on he right node or queued successfully.
> 
> Minor typo -> s/he/the ?

Yes, that comment needs some help.  This?

--- a/mm/mempolicy.c~mm-mempolicy-make-mbind-return-eio-when-mpol_mf_strict-is-specified-fix
+++ a/mm/mempolicy.c
@@ -429,9 +429,9 @@ static inline bool queue_pages_required(
 }
 
 /*
- * The queue_pages_pmd() may have three kind of return value.
- * 1 - pages are placed on he right node or queued successfully.
- * 0 - THP get split.
+ * queue_pages_pmd() has three possible return values:
+ * 1 - pages are placed on the right node or queued successfully.
+ * 0 - THP was split.
  * -EIO - is migration entry or MPOL_MF_STRICT was specified and an existing
  *        page was already on a node that does not follow the policy.
  */
_

