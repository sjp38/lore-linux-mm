Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA5FAC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:53:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B94D208C3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:53:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B94D208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09D696B026D; Mon, 13 May 2019 04:53:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04D346B026E; Mon, 13 May 2019 04:53:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E58566B026F; Mon, 13 May 2019 04:53:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 995506B026D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 04:53:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d15so16917378edm.7
        for <linux-mm@kvack.org>; Mon, 13 May 2019 01:53:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fJ1WyILG9AMBeCt6XjjkG0lQYb4oxHO7ZMF8WXIccBE=;
        b=EHFYgHgi9bWC11htJ3hXxTlRHOLs4X2FC6F1fre6G1X+/MbxqGu5WaU/LbHSL7rRhb
         9mMNPEdKqLNWsvpRe5CZzjrH6FTysD/7lUzkLud+xrILU4Z33wgDpw7PKjMIiu7YlTTl
         BuDycvhiJkuehj1RKHNSs2eTXl3iXsMDmfsw3ySMggphUKZB1rXeJ73sWW3mx02LrcYz
         9Crd0Q/h/UwOA41+Yv3BW21WoCW6ycYV1QGupQA2jJke1wU0M3z60b9Bq+I8GX5+J8EH
         VfqUbjBNhdCeBbpy6vVCilTgTCeE3+amVC7/6brDG0z2lmsZBNOmvNjsn9ZONB8i5T4c
         qVkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAW9Et10215IYrGuPZP1yqGiM393SQHaJPfsgmz/Fy4ek7I11RM8
	vIHGyf3ooipL5idoLz+/tkj3KW12vuU7XwHvqZ0j2zah+wE4wUFLVDCk5jaIKGrGxKlwzlaaTiM
	ruQM2PzMg/l4x1TD39JzlMOyEeBAjRrFsy6EKgDA51InwxNrXk+CJVV6GsCpxTTkkmA==
X-Received: by 2002:a17:906:43c4:: with SMTP id j4mr21058036ejn.262.1557737587209;
        Mon, 13 May 2019 01:53:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzY5izWsCm8ARqUoABnTWAGcZNb0Clpc/FJPNtMQQe/R2M9ApJ1xOzlYlaPpOqk7HAEJOMj
X-Received: by 2002:a17:906:43c4:: with SMTP id j4mr21057987ejn.262.1557737586348;
        Mon, 13 May 2019 01:53:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557737586; cv=none;
        d=google.com; s=arc-20160816;
        b=IaqLbDrnDcILCxEMct5GRuMYelTqJjLX1ZGKBY47RobYuda9DuVjdO/NPhjPEZBkel
         0QCtQshXhQ5L1L4M76p8cTbVoApS2qb0GtR4iC0Pxpru/TZeADTESw0tw6vT9TUaH0ip
         JILY6NGWxKuWyHIols1BjR1ACRtlcWUBN8Fs6LtaTP7xDJCC2YUpe7zldEa0yXUlMLLb
         wVfcQm1m+Rs8z/xdUr/l0yyKCu6EMBlCsDaD+GZpAQbM0zjuQMVob5KhuUf9yGf73elM
         rKbxQawJAzPM03woQGrCze8Enxv7Je07S50s4gIyIgZQwCjz82eDaprJT2mV22jaoo3e
         5xTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fJ1WyILG9AMBeCt6XjjkG0lQYb4oxHO7ZMF8WXIccBE=;
        b=KyqhjdbdIE0jslD7ErsvvH5qW1kEbsrxdDEJi1X9vm5rBqA52yfk9QipJuFY7fi71y
         poYbIzfERU7XGA92XDFw8fOK5q389KRWful8zOxoRltDUIgAf/PswVlMSdVeKscLrdsT
         8G7JNUrPVfBlr5nrIwoIBRUeoWwmy4QHVGQ1Yi0ZVn1z6K3gMhzaW1puLPO1HMQ/yIGu
         NH3b83uyjWozW6jxqH7FEvjIfsaEaeEcAB/YgYX4/f5+aGH0zWmaFsiD9NqMKG3TFvvN
         fARDlK7NYBEPXJx2VRO9MU9EpOhcI5dCmaPzMITqk1d0LbZpWDPuav4ft6t6krUL6Dud
         yOpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id i26si884343ede.246.2019.05.13.01.53.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 01:53:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) client-ip=81.17.249.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id DBBD0988D1
	for <linux-mm@kvack.org>; Mon, 13 May 2019 08:53:05 +0000 (UTC)
Received: (qmail 16351 invoked from network); 13 May 2019 08:53:05 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 13 May 2019 08:53:05 -0000
Date: Mon, 13 May 2019 09:53:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Bruce ZHANG <bo.zhang@nxp.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"guro@fb.com" <guro@fb.com>, "mhocko@suse.com" <mhocko@suse.com>,
	"vbabka@suse.cz" <vbabka@suse.cz>,
	"jannh@google.com" <jannh@google.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH] mm,vmstat: correct pagetypeinfo statistics when show
Message-ID: <20190513085304.GJ18914@techsingularity.net>
References: <1557491480-19857-1-git-send-email-bo.zhang@nxp.com>
 <20190510184900.tf5r74rtiblmifyq@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190510184900.tf5r74rtiblmifyq@ca-dmjordan1.us.oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 02:49:00PM -0400, Daniel Jordan wrote:
> On Fri, May 10, 2019 at 12:36:48PM +0000, Bruce ZHANG wrote:
> > The "Free pages count per migrate type at order" are shown with the
> > order from 0 ~ (MAX_ORDER-1), while "Page block order" just print
> > pageblock_order. If the macro CONFIG_HUGETLB_PAGE is defined, the
> > pageblock_order may not be equal to (MAX_ORDER-1).
> 
> All of this is true, but why do you think it's wrong?
> 

Indeed, why is this wrong?

> It makes sense that "Page block order" corresponds to pageblock_order,
> regardless of whether pageblock_order == MAX_ORDER-1.
> 

Page block order is related to the PMD huge page size, it's not directly
related to MAX_ORDER other than MAX_ORDER is larger than
pageblock_order.

> Cc Mel, who added these two lines.
> 
> > Signed-off-by: Zhang Bo <bo.zhang@nxp.com>

What's there is correct so unless there is a great explanation as to why
it should be different;

Naked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

