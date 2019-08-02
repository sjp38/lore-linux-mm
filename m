Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF97DC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C4F02087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:12:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C4F02087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 213426B0007; Fri,  2 Aug 2019 15:12:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C3476B0008; Fri,  2 Aug 2019 15:12:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08C396B000A; Fri,  2 Aug 2019 15:12:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D17656B0007
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 15:12:34 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so42126448pls.17
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 12:12:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OrxJyZknZW+o+SEWnxNKZhqfVLYXIWmAf8QZUekZOnQ=;
        b=QL4VVgYo2XlLB/HRwVX541hxqA5wM9hwDFJWNKr7UHWf72/eU1dqDje6jKfbTh8HM4
         ODmhe/OYG+linIPpohsKn1FDfKysvPV2TxmyrJPz4s8HxwRwEr0qfoLpPjzNnngFVdtG
         jNMme71p5PiehO3yLsyhP3/2MML1ihz/MAYdynwxdFaDbvEP3itMNJVGpFzZNgnIAR4m
         qHk5UiXnniF4o+tLppQGSMx7zsIQlcXLffturZTrHPUOGyup+Itto3pJblLcJvBWbIrA
         5CGAwwKqcWfj6oQmLFXdGel+AtTrcoFQCjjpQoRY8xOqAgbdc8uvS35yG2yeqsYMOLAC
         +Dlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAX51NCNrizQVUYiXqttW1t1HVYEe/uTUtm2bpk1kancqPQ99NUM
	2Q2oZuoN8EJGVmajltW1709LqP/ocswlKo7gSYytb+qh1vQMk4MZl6L8H2j5N61n8mPCy4W9sSa
	98dzGYoXHX49aLeld/0citi8/2NQr8b7sLhjZcaGzYwz/LMDlJAfWNxV4Hnq05wSfOw==
X-Received: by 2002:a17:90a:25af:: with SMTP id k44mr5662363pje.122.1564773154539;
        Fri, 02 Aug 2019 12:12:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxETmRUZyqe8r7OM2qxkJda0XEi2Dfv4Q8LdHSV1XBXzKRwgBgMGr5teAzmy1e7tmNjwGZq
X-Received: by 2002:a17:90a:25af:: with SMTP id k44mr5662311pje.122.1564773153768;
        Fri, 02 Aug 2019 12:12:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564773153; cv=none;
        d=google.com; s=arc-20160816;
        b=xKZQSOSPSRSeGKpm8yO+1rWohGVUWAoJk4xLE9ei3lA1w0kA/QutEK3qgYpFoC8baS
         qEFUQ36L4sCDTL5abo3EXWaEjq0x/ZCiPTlZvboUf2UNGXaKKyw9Zevs2EgC3QlzxcI6
         m44IT0oumwVPk2dcSWgbret3t8+4YV8zYP19MdxSNm6qbxu+yLzHU7mgh3ab+R2kpuBy
         BWksVjy8u/JkwmcvfzmHNSVJk2WSwjnXXMJjkOGmEJBpRgopgms+m2SXjh1gfeihbl1q
         Kz9Zg2evwGanlnkMPsiBjrdckMMD8XKRW6lBsvYryvWinyfC9fogdhQbZhRY+MYzGSTR
         57ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=OrxJyZknZW+o+SEWnxNKZhqfVLYXIWmAf8QZUekZOnQ=;
        b=ZPa9yy9v8MATThoIJmv0wkrBsUGOpR7sZInFR9sLjBPQBcSTegFrWXDKMPfo450aUu
         aNuCQljvfZfUG6i+hXnwjB7OLX5318YfpwipzGer0ELDeksTWWue482HyJ8xuvYaaZzK
         zwApcv8JyGGYf9ARd5epgj42mhv7s6Y7tcfg+x/bRL+yUUJQTEPzBlKTrqBURZDWS9xE
         lckBMDHjsHECV6/sDDpVhtglXyF5FdCCiMAHDp7q/IC57cP1fOnJATRPRD3osgSLJyHZ
         fg3YA6KRFc1+dkp4wBtY1aorj7N04W8fp6zWvFIdoz+Acw6hqc1lOW/sq05DocDGB9Jj
         bTPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v23si807609pgb.496.2019.08.02.12.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 12:12:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 76EF1167C;
	Fri,  2 Aug 2019 19:12:27 +0000 (UTC)
Date: Fri, 2 Aug 2019 12:11:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org, John Hubbard
 <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Jason
 Gunthorpe <jgg@mellanox.com>, Logan Gunthorpe <logang@deltatee.com>, Ira
 Weiny <ira.weiny@intel.com>, Matthew Wilcox <willy@infradead.org>, Mel
 Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko
 <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz
 <mike.kravetz@oracle.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>
Subject: Re: [PATCH v3 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
Message-Id: <20190802121147.d7e6a5eb57966b98118abb97@linux-foundation.org>
In-Reply-To: <20190802083141.GA11000@lst.de>
References: <20190724232700.23327-1-rcampbell@nvidia.com>
	<20190724232700.23327-3-rcampbell@nvidia.com>
	<20190802083141.GA11000@lst.de>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Aug 2019 10:31:41 +0200 Christoph Hellwig <hch@lst.de> wrote:

> Andrew,
> 
> Any reason the fixes haven't made it to mainline yet?

I generally let fixes bake in -next for a week or two, unless they
appear to be impeding ongoing test&devel.

[3/3] shows no sign of having been reviewed, btw.

