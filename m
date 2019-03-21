Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0919C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 02:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8DE9218AC
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 02:58:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8DE9218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 539266B0003; Wed, 20 Mar 2019 22:58:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E93F6B0006; Wed, 20 Mar 2019 22:58:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D9A56B0007; Wed, 20 Mar 2019 22:58:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCE06B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 22:58:09 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m17so4508960pgk.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 19:58:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r8S+jClzHX/8fOlxgP+qvzx4oMnBb47JLFc8pCCSjks=;
        b=oQbXws4jZ9fx5I9XWI150Q4fX+AoxLD79yQMEQZz0MWdtjOPcgj1EFHauYGtt7MjPf
         0gNQIvol6Aap9fJxExXHT6BziBFRAQZtLIU1A0SwXlh2EFQDrBUHjEScZXFZv26DeWJE
         iQp+aAzcesqp7MiDFFI9hbohmAdw8Be7KtUD3yxu+9ludeyj7zoafTxf09pSLOzvAY5m
         RIZ6maAOK3aIwSVbohID/8cxJira5662TAY0FSVeSlnwklaVjHH4pQb7BreRkc7TZHsU
         ShLkTChoISopymwZfjmYKYdnQdFQyb1mXshMbdYwfk181uvuGlp01lvMCtYiBtCVTRcg
         eROA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAV+qMAynJWgLtjTP4JDsDsKN03K2ZVNYs6KOuZII3obewQLKXRh
	xL6ExirklgyrBPVdZOGfs3Zfv4YVrFlCjkmietAWqfcRPEz6GQ3V2fXZ971PutnOhXR91v3IltE
	U2la1kF7FpE9TQTmeVBJEk37lgfG6YlAgt5otjO+/gRX/fPATlzJ/2wTOY1gp+E9cCQ==
X-Received: by 2002:a17:902:e60e:: with SMTP id cm14mr1211199plb.192.1553137088706;
        Wed, 20 Mar 2019 19:58:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzObEWlgAotja0e4jc3HEKXk5zLnNENFoyA6Fhx/ZkPrCgpItHeF2Pg9g2Ns1/DxBdgshHd
X-Received: by 2002:a17:902:e60e:: with SMTP id cm14mr1211147plb.192.1553137087823;
        Wed, 20 Mar 2019 19:58:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553137087; cv=none;
        d=google.com; s=arc-20160816;
        b=Qp6h0zwf9x5h9GQYvrNIRs/WuZP/0S7DeDUxAwrFRgLUHYVujjr9hyuBQVpwoSHU2d
         ePEp22ocFmYwHxXJjQtdM01tnLotRZpw3b4NKEburCVtP7pSLgpvwwp2bxPPRsHMhhX9
         gYZ/269A6da2WFIX0UMJ6VxQqKYs59ZmkjHPLNWr4+2mKkTo7VcBtk5a0fGOge1oFNUB
         pWIvR3Cpgw2Ihz3K/oFaP3fgPnBfj/Y++3W4s+nATGvG0xYXgWiWfC6p0zHYtHQSdfLr
         WnTivCCiDCdTlBhn0bd3fliUjcI2YQri0DJsMIYD/efrDa6sMkDjtzz0BFjZFFuEW/yG
         sLtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=r8S+jClzHX/8fOlxgP+qvzx4oMnBb47JLFc8pCCSjks=;
        b=g5CsEWis+IcUm195lIh4JsYWWMGYbnvR/5yk+oFuiUOKeyj50Cl81rTFbCs8IqAyzU
         ufG5LdpTHWmkJp5zRPvQID5Phzp6TGSwgb9JKykfhoiVr7iqxuykRJMbOQ3Sjc5GuitV
         kf7VlcZBM6pkVJOR0DDveSDMPmqV3ErIh7qiXzSablqdY6wbyxKpqmhLt3ptexrROE1Y
         jkuKUEgWjFwwsHbOehTHLB7JyWSWuv/+GXjAGsS1150IaJL1kgkxQrAG5EppXfiOX2cl
         etR2noAxyagNbPryO5wZUqwPfh5/sh3cuA1f3gCYK5ePYQ752lA7ILrh2YWHg257EKIf
         NgNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i18si3041049pfa.205.2019.03.20.19.58.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 19:58:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 03F211814;
	Thu, 21 Mar 2019 02:58:06 +0000 (UTC)
Date: Wed, 20 Mar 2019 19:58:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yue Hu <zbestahu@gmail.com>
Cc: iamjoonsoo.kim@lge.com, mingo@kernel.org, vbabka@suse.cz,
 rppt@linux.vnet.ibm.com, rdunlap@infradead.org, linux-mm@kvack.org,
 huyue2@yulong.com
Subject: Re: [PATCH] mm/cma: fix the bitmap status to show failed allocation
 reason
Message-Id: <20190320195805.657a0c87bb54e678ebd54c23@linux-foundation.org>
In-Reply-To: <20190321101721.00006f19.zbestahu@gmail.com>
References: <20190320060829.9144-1-zbestahu@gmail.com>
	<20190320151245.ff79af49fe364ac01d4edb14@linux-foundation.org>
	<20190321101721.00006f19.zbestahu@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Mar 2019 10:17:21 +0800 Yue Hu <zbestahu@gmail.com> wrote:

> >From perspective of bitmap function, the size input is not correct. It will
> affect the available pages at some position to debug the failure issue.
> 
> This is an example with order_per_bit = 1
> 
> Before this change:
> [    4.120060] cma: number of available pages: 1@93+4@108+7@121+7@137+7@153+7@169+7@185+7@201+3@213+3@221+3@229+3@237+3@245+3@253+3@261+3@269+3@277+3@285+3@293+3@301+3@309+3@317+3@325+19@333+15@369+512@512=> 638 free of 1024 total pages
> 
> After this change:
> [    4.143234] cma: number of available pages: 2@93+8@108+14@121+14@137+14@153+14@169+14@185+14@201+6@213+6@221+6@229+6@237+6@245+6@253+6@261+6@269+6@277+6@285+6@293+6@301+6@309+6@317+6@325+38@333+30@369=> 252 free of 1024 total pages
> 
> Obviously the bitmap status before is incorrect, i can add this effect describtion
> in v2, but seems the patch has been merged?

Thanks, I updated the changelog.

