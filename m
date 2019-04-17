Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED1E0C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 03:24:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E6F120643
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 03:24:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E6F120643
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAE726B0279; Tue, 16 Apr 2019 23:24:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5E006B027A; Tue, 16 Apr 2019 23:24:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D27BB6B027B; Tue, 16 Apr 2019 23:24:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 976F76B0279
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 23:24:24 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q7so14624622plr.7
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 20:24:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Cg0d02vy/RQj5LneO6PAOChysg515q8Usk/hVGuCNd4=;
        b=bNbEFzqU69r4QM1wjnf+WV3GIp37yY1qKQd3CYznPnanMBF046KmlmSJiQEa+aLvrc
         U5gm4dadhRQr5RI0uqAHEwzlR2sQzS3U7AFHulCxaDkez3qHPsBPsuns20LtLTpOWOKI
         7gEO1s9KPN9rQeoIFkWSrbB+9kcjyrxjmiY2lIHXQ2EhtsQHerkJx1KG6XsqwlznlgDj
         GthHpnmax5JbXmXpBX8jFPUac5P0LBhx3oZpHKKoGMeqVoNUMIJ26zm+9U2XKh3ZO0Qx
         hA1G0GJgjqbTZ0ek3t5i2rla+kQKWQteipHBuJoJE1DqJ7S4M5KQM2lXwGP/oegvMQxT
         gYyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXm50BbDAcR5kHWKdHkchxUIQizcc9gWU3LqmUCls6qDRiIGWPO
	zCVe1lHCz6hlZMaPJ0sRQRfdRRmotMvrjL7zWUg5F2GZs5zOVefUfkXjijtRGgewFKn/Ewz4zQA
	AeLc1IUm3dMLMhjb1heWV2WInLSbAHeT/VOReqBRXl8eLV2DzdN6kKGEo/8d9NKbNyw==
X-Received: by 2002:a62:209c:: with SMTP id m28mr84790010pfj.233.1555471464237;
        Tue, 16 Apr 2019 20:24:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJPnBTsY/Pzm0EAJtkOL6C7w7P9HcI9r0h8fIroBlV3xSXa2WJX10c7FezLR8jQMz5a+C5
X-Received: by 2002:a62:209c:: with SMTP id m28mr84789954pfj.233.1555471463440;
        Tue, 16 Apr 2019 20:24:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555471463; cv=none;
        d=google.com; s=arc-20160816;
        b=E6pDFsPvJ0BZJ44bg2vxDT9ZBY5q0F2iu4uv48J7XwgiE2PCWydnHYgGMcdk/v8wGf
         wnidk4GHB7bwzQtrlvr1F1HbT6e8E72e8dVBLv+w4dcZLwJZ8EWywtIRMsSW/2N+ykNe
         Spiha3VRC+2lPF0BECSHlTB94ZZBYnuK57XqNOTBJ+OQPn9AbTKZOyJt/7rlRbF/zsCF
         5xZ2dzSQBaCIZnQvjByOhHv4solzMK2X0IAoJDpzVaPvLZGr6MzttXm9ViRDV0lmeEW0
         mfv5YyNX0leo0BOv0zjnYmlWybiRbokRlRsF4skMYMUU8d8nwFHHlid/mYtanGUqB87c
         EFNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Cg0d02vy/RQj5LneO6PAOChysg515q8Usk/hVGuCNd4=;
        b=Iapfq+tQvGBTVZ1octML5hnHjZM/BVPY0bfxVoscACxiUD+62s+B17B1b9jM3adw8N
         9zehbjp3fEKisiufXHjZoSvzKnaH+4SH01wvwxOHIKeuRYm/w5W5LFsePtOstn7IVwoK
         PNG2n844Ck0mx3Ad2CDM6tj/44HUSMo1KGD/EWaG8TkvR1xFyJzTpGLMX6RT3jSNzAvD
         Yoep+2KKcHW6RTntXxPYWoMxPMwxHbLNzz8qZCaweCJT0h7a4cXUfrRBnyxhaqm6voKS
         aps5sL5zqcHJE9AIJmgj6mSaDLb/gb66ehYSOb5JsY8Z88Js3f5GHt3Yi0F1xjWWN/y3
         61cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t22si49240109plo.74.2019.04.16.20.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 20:24:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 7D8A6B65;
	Wed, 17 Apr 2019 03:24:22 +0000 (UTC)
Date: Tue, 16 Apr 2019 20:24:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Guenter Roeck <groeck@google.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Thomas Gleixner <tglx@linutronix.de>,
 Mike Rapoport <rppt@linux.ibm.com>, Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH] init: Initialize jump labels before command line option
 parsing
Message-Id: <20190416202420.9acb6f56fd10e7f84446e75b@linux-foundation.org>
In-Reply-To: <CABXOdTdSNgEnn+mEk-X5ZWph8rCz+yW7EKiA-GHnZdsBC3rsNg@mail.gmail.com>
References: <155544804466.1032396.13418949511615676665.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20190416164418.3ca1d8cef2713a1154067291@linux-foundation.org>
	<CAPcyv4iJxyiGWqjGKLuRgjr9UgDO9ERSghUi3k597gk=X5votQ@mail.gmail.com>
	<CABXOdTdSNgEnn+mEk-X5ZWph8rCz+yW7EKiA-GHnZdsBC3rsNg@mail.gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Apr 2019 17:39:03 -0700 Guenter Roeck <groeck@google.com> wrote:

> > > Has it been confirmed that this fixes
> > > mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch
> > > on beaglebone-black?
> >
> > This only fixes dynamically enabling the shuffling on 32-bit ARM.
> > Guenter happened to run without the mm-only 'force-enable-always'
> > patch and when he went to use the command line option to enable it he
> > hit the jump-label warning.
> >
> 
> For my part I have not seen the original failure; it seems that the
> kernelci logs are no longer present. As such, I neither know how it
> looks like nor how to (try to) reproduce it. I just thought it might
> be worthwhile to run the patch through my boot tests to see if
> anything pops up. From the feedback I got, though, it sounded like the
> failure is/was very omap2 specific, so I would not be able to
> reproduce it anyway.

hm.  Maybe we forge ahead and see if someone hits the issue who
can work with us on resolving it.  It sounds like the affected population
will be quite small.  But still, ugh :(

