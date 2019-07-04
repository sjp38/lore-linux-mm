Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59BF8C46497
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 19:53:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06251218A0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 19:53:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YrQuDPw+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06251218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DF006B0003; Thu,  4 Jul 2019 15:53:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78F4A8E0003; Thu,  4 Jul 2019 15:53:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67F248E0001; Thu,  4 Jul 2019 15:53:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7216B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 15:53:52 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z1so4192124pfb.7
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 12:53:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZRihdfEXVe9649KoIxE89y4jwywMzdPzaXv0AiZ1LlA=;
        b=WmJZUPTVANVsglD72djJlPTHkL/V9YqSyVrugMgLWUJR23+6vZLU/UqMN8wMh3ZVbg
         ArZQi3YlnGs61x+oLX7UkjvVVw1D75uPVFEsQx0+ja3lc/Cut0XcqSXC4asJ8Ih9KA7D
         nm9TixZklkAdWGBeEhMiPxocN0gs8Vjwf2RVB9BPH9DmfUez7IK8sM18mETlFHg7lqaG
         QQgTPsETWWPP/fl8i56pQInxx28coHJ2PWJe7MDuU4u/mZ5hP3YZ2HPKPjwpvLmCaFgm
         8jI6m9wLKn8MX/gWkBMdR76uRd4J5r4+yz6rdrRWdV+GFkaPiiKm7Iza/EB96a1/HIyS
         4U/w==
X-Gm-Message-State: APjAAAUVcXmQ8T33HCqnkDSjmYBhj0AVF8Vj+QO25VrSo10kumr0fW6V
	mX4hWZY/3AvPUSR1URcd504eRx2fO7d37kcKWaiO+i69hmCTRZvdK3f+SZLaJK6EWdPweYSszof
	DgankZBrqNUdo6S++Lebw4ttKgm9zaqLbeowhIrdO/84dcQ7YzdyXHX1rD9D1ib6gTA==
X-Received: by 2002:a17:90a:3270:: with SMTP id k103mr1291793pjb.54.1562270031820;
        Thu, 04 Jul 2019 12:53:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqsAtGaAVpC1PFjOUIdz7fDMHaqBGNAZzE1Npn7hvKnDnhLSXNygcInKUdtnRnVKWRJZg6
X-Received: by 2002:a17:90a:3270:: with SMTP id k103mr1291761pjb.54.1562270031179;
        Thu, 04 Jul 2019 12:53:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562270031; cv=none;
        d=google.com; s=arc-20160816;
        b=ou4V4FkFyLnF5tyv2kCWf+mYWBxpyD9vE/Ur9PePwlCYwt8D1M37EF9YIUq1+yjbxY
         /UWHVw3ZlARooqwMgBgkwu3bLkyd3sg1Wy/7rKOORq+7YrHB6buGJbiT9R6VnUd674+w
         aSZYwIO2fnbV4RqofQSR8Nlo38tXXJbDdH00nGCTuhfyEWAwsuWQXhURxvnWKQodgZPl
         1si+UMe6lzz9MioATGpRwElLoemyhOYPK9CqXW58sCZ8JqHXvTiWMvjUujJwn55iJ+0h
         18qV+wfTXRbKDtFT4hJjzzJNeN37mnfYBae5RZd6jeJWspy18DU+Q4BNB104tGrBZCYd
         KBVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZRihdfEXVe9649KoIxE89y4jwywMzdPzaXv0AiZ1LlA=;
        b=e1Lqg/DoCSRBDGlFA6ABZDSLRMAQcDzCm2fMJRpdJrrKLaO2KxxgXrFvrpvG0RxppS
         lMGu8nTXqhOpKlYNAr7E7RXxh9iHsW5EGmt/Boh+OMPcgl1TDoahDJMCOecO+Ztnhl76
         uQOlh3/eqHhLfvzqh+YPqvteav3HJKIsn3+oNBvsov7mnNuwBjhBb1nI77xfplu3z9hm
         qiKGE/ikros4yubSUGQ68zNga0DEToE/vmXokrnYiXwqdrez+9x470JF6VUK4fq7a7LP
         GGAo4mCStyKLCmeRcfxqeWJW45vojcOOYjHxpQnZlz0dYo+WO9xVHOpX/smGjwrJtqpM
         fj6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YrQuDPw+;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q191si6298207pfq.63.2019.07.04.12.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 12:53:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YrQuDPw+;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EBADA21852;
	Thu,  4 Jul 2019 19:53:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562270030;
	bh=D8dJJX8KT2Xl8Nh7bMvZgekUUmiAou9NFBVZsil11Lc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=YrQuDPw+rga1xtwxOX16kcC0a03XtrEZuxO6OMtfMYRlXCWQXEwoRhtzXiTaMi7UH
	 aY85ep5KDVRdkbbC3GGx6CKhK/VzlWNWBObEqB0mE5xBp8a7JvEcKmCN57ocm/RBNl
	 1jkz+TotL/QtoBgpN+wyIXo03MdfNEnor9UGm1Tk=
Date: Thu, 4 Jul 2019 12:53:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexander Potapenko <glider@google.com>
Cc: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
 Michal Hocko <mhocko@suse.com>, James Morris
 <jamorris@linux.microsoft.com>, Masahiro Yamada
 <yamada.masahiro@socionext.com>, Michal Hocko <mhocko@kernel.org>, James
 Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, Nick
 Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>,
 Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>,
 Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>,
 Jann Horn <jannh@google.com>, Mark Rutland <mark.rutland@arm.com>, Marco
 Elver <elver@google.com>, Qian Cai <cai@lca.pw>, Linux Memory Management
 List <linux-mm@kvack.org>, linux-security-module
 <linux-security-module@vger.kernel.org>, Kernel Hardening
 <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v10 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-Id: <20190704125349.0dd001629a9c4b8e4cb9f227@linux-foundation.org>
In-Reply-To: <CAG_fn=XYRpeBgLpbwhaF=JfNHa-styydOKq8_SA3vsdMcXNgzw@mail.gmail.com>
References: <20190628093131.199499-1-glider@google.com>
	<20190628093131.199499-2-glider@google.com>
	<20190702155915.ab5e7053e5c0d49e84c6ed67@linux-foundation.org>
	<CAG_fn=XYRpeBgLpbwhaF=JfNHa-styydOKq8_SA3vsdMcXNgzw@mail.gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jul 2019 13:40:26 +0200 Alexander Potapenko <glider@google.com> wrote:

> > There are unchangelogged alterations between v9 and v10.  The
> > replacement of IS_ENABLED(CONFIG_PAGE_POISONING)) with
> > page_poisoning_enabled().
> In the case I send another version of the patch, do I need to
> retroactively add them to the changelog?

I don't think the world could stand another version ;)

Please simply explain this change for the reviewers?

