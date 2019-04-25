Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FFF5C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:09:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 377252077C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:09:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hwCGJgJL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 377252077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7438B6B0003; Thu, 25 Apr 2019 17:09:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F10A6B0005; Thu, 25 Apr 2019 17:09:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 609856B0006; Thu, 25 Apr 2019 17:09:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23EDC6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:09:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e12so530467pgh.2
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:09:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aaJkYEA6VyDdQHuuWqfQer9DDNRHbyTQjCC7r2fnf54=;
        b=M4NePnUiadJbTHEMLHrge1PTdPKIUMWEyDZ8qkLRJQdHYiJft7Hbqe9Yo0H9gSLv07
         kTqjv2c8s6QtzQE4gI0/6paLqy41eH8kD7tUZE5vJUJ71oxwGDu3hS4OKKuwwHtY9EHB
         s2+f/RODpGgISC8PO9ZEkODMgyLSRSoN3MgaNUTc2FJ7308/59yonSgyMVHWposdmoaf
         R9xxwLxs4Jzlv9pqmGkWYJpY92NMgznQ+RMe4IFVnp9uyK2hPifHW6UaN5tsXdW5Mgaq
         LU3UB8WxSFoDhLYmpkdJoIzn0BY0BYX2/o+jSgGLukJ0rb3QNURNR57qqts6sKyLDNcE
         ftcg==
X-Gm-Message-State: APjAAAXvGnvVZtJ+17nEDYEfoDOrDkQTSNYkJCDDtybUdnDTcOHE2maX
	yPYncuqFC+EZ8SPOUPAL+nVQCwIijk3GgpWfFof5TvtC/WxE6WTyQ0rDSqL4D9cccaKMYYNVscS
	NXbl80feX+31iw3wRQOiggrUgf7rXvKh61iv3ahqwgnu3SXhqAtGIm1tfc2hIHNR/cw==
X-Received: by 2002:aa7:90ca:: with SMTP id k10mr41579622pfk.144.1556226549752;
        Thu, 25 Apr 2019 14:09:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6gFOq1CbuB1YSAFnI9JpKdyGV28BNQXeOx0W3B/8oz4KRbrxWpyv+qSb6StcgjpwkoHb4
X-Received: by 2002:aa7:90ca:: with SMTP id k10mr41579564pfk.144.1556226548990;
        Thu, 25 Apr 2019 14:09:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556226548; cv=none;
        d=google.com; s=arc-20160816;
        b=favJl3NgGNIElkR6jrWIiKLkl8J9xDjVwGjbv3BlvAmVer7Uu0HQzFFLEQoN4s8zRl
         L4Uj2nyJSu/vb0E0fU/nk0pxDcuPeGX9kOJN+bx0VZJj06Mel4ZnoVWPdA8AkMRmevkg
         Au4pFdAlPAX7XMPVCOaNBf3TW+nipSnZv0L2PWn4zaxknPAQOPQqk5o8xOh49lY5oWLr
         JkNH9Z+U6B8o+NU1FQyVjuJPe672JLH6JeaxxXR6O9wzjm25O4drzEQAY50JR3EyrN8Y
         hCF7wXHd/Z3P7JS8HK7VVnDBahizI4895Vpu2iUyG/w0zmNJ/Qv8SO+y28QRa1Cq19tU
         OErg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aaJkYEA6VyDdQHuuWqfQer9DDNRHbyTQjCC7r2fnf54=;
        b=pxf6AvoWAUcRJKWYpGPJMVrpXlRepBNGfnFD6lPdZ7NVRm/Bzn2vCMxSjH8FK62RKb
         zQpGZK51e/uCA1SWD0IF4if8cxeI4dsne3sag9TU0vtWBqFmYd4FARhCydMRVr7zeJtN
         YdE7aVtK5FDYghrm5utYEc/TaClvHr/Jt4hNGOlDrGLasj+gFzKoRNAxoVqv9UfESyJ9
         cOJHXd9kxJxIXNnywX7qc3gilyRpKd5Nrx8afa3drjxaH8svJnqpidt4kwpLeiiZffQA
         /D833mXeEKLTyEBUK2nC0jtVz68CeNgluVSzCEtPSXwXQu1PDDDycXoZPg2GAhN81TVP
         Fmsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hwCGJgJL;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f16si9319114pgi.496.2019.04.25.14.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:09:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hwCGJgJL;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B70E0206A3;
	Thu, 25 Apr 2019 21:09:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556226548;
	bh=WpmCo0Eolh7ocNua2jKlJaDc65LagGI+szT8NXdlDyI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=hwCGJgJLgap2sUcaotmg2GU3j2hAAro/ij+TdeK6m1lWq8XFJuzwuuIjvpKGfVhbm
	 UD4cSWul8/LRGi3W/6wnjPlPNmsQJjnzUYoBYU+ANMKe24twKNEkaj5q7jzC1wW3Sw
	 1aTtd63UZ1hCSFe8WEnDMt/XxyrkFTGKvz3wEooc=
Date: Thu, 25 Apr 2019 14:09:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm/page_alloc: fix never set ALLOC_NOFRAGMENT flag
Message-Id: <20190425140908.7da3c4e52663196c7b914b00@linux-foundation.org>
In-Reply-To: <20190424234052.GW18914@techsingularity.net>
References: <20190423120806.3503-1-aryabinin@virtuozzo.com>
	<20190423120806.3503-2-aryabinin@virtuozzo.com>
	<20190423120143.f555f77df02a266ba2a7f1fc@linux-foundation.org>
	<20190424090403.GS18914@techsingularity.net>
	<20190424154624.f1084195c36684453a557718@linux-foundation.org>
	<20190424234052.GW18914@techsingularity.net>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Apr 2019 00:40:53 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Apr 24, 2019 at 03:46:24PM -0700, Andrew Morton wrote:
> > On Wed, 24 Apr 2019 10:04:03 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> > 
> > > On Tue, Apr 23, 2019 at 12:01:43PM -0700, Andrew Morton wrote:
> > > > On Tue, 23 Apr 2019 15:08:06 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> > > > 
> > > > > Commit 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
> > > > > removed setting of the ALLOC_NOFRAGMENT flag. Bring it back.
> > > > 
> > > > What are the runtime effects of this fix?
> > > 
> > > The runtime effect is that ALLOC_NOFRAGMENT behaviour is restored so
> > > that allocations are spread across local zones to avoid fragmentation
> > > due to mixing pageblocks as long as possible.
> > 
> > OK, thanks.  Is this worth a -stable backport?
> 
> Yes, but only for 5.0 obviously and both should be included if that is
> the case. I did not push for it initially as problems in this area are
> hard for a general user to detect and people have not complained about
> 5.0's fragmentation handling.

Ah, OK.  0a79cdad5eb2 didn't have a -stable tag so I suppose we can
leave this patch un-stabled.

If they went and backported 0a79cdad5eb2 anyway, let's hope the scripts
are smart enough to catch this patch's Fixes: link.

