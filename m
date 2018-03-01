Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24F406B0005
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 02:17:58 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id r18so2744777qtn.17
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 23:17:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w10si4014522qkg.351.2018.02.28.23.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 23:17:57 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2179UCS064022
	for <linux-mm@kvack.org>; Thu, 1 Mar 2018 02:17:56 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gec4sswjv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Mar 2018 02:17:56 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 1 Mar 2018 07:17:54 -0000
Date: Thu, 1 Mar 2018 08:17:50 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v3 0/4] Split page_type out from mapcount
In-Reply-To: <20180228223157.9281-1-willy@infradead.org>
References: <20180228223157.9281-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20180301081750.42b135c3@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

On Wed, 28 Feb 2018 14:31:53 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> I want to use the _mapcount field to record what a page is in use as.
> This can help with debugging and we can also expose that information to
> userspace through /proc/kpageflags to help diagnose memory usage (not
> included as part of this patch set).
> 
> First, we need s390 to stop using _mapcount for its own purposes;
> Martin, I hope you have time to look at this patch.  I must confess I
> don't quite understand what the different bits are used for in the upper
> nybble of the _mapcount, but I tried to replicate what you were doing
> faithfully.

Yeah, that is a nasty bit of code. On s390 we have 2K page tables (pte)
but 4K pages. If we use full pages for the pte tables we waste 2K of
memory for each of the tables. So we allocate 4K and split it into two
2K pieces. Now we have to keep track of the pieces to be able to free
them again.

I try to give your patch a spin today. It should be stand-alone, no ?

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
