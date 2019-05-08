Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B14D0C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 17:07:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7087721530
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 17:07:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7087721530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A4B56B0276; Wed,  8 May 2019 13:07:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15DC66B0279; Wed,  8 May 2019 13:07:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01BA76B027A; Wed,  8 May 2019 13:07:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9C1F6B0276
	for <linux-mm@kvack.org>; Wed,  8 May 2019 13:07:18 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so11890879plq.1
        for <linux-mm@kvack.org>; Wed, 08 May 2019 10:07:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yMEWSrYrkBtNCnMGeX0baXrNh/pC/64KM+hIHnSkEPs=;
        b=Veyemrl5cSFCSuJ40lID9iseYbP8v8e3HAgL7ATCZ/f57cTC0FF3hBCYyTJrAIfmC8
         UiDxpvd2a3yB+epwhp3S2hQn05NXcWpiWSOHD35uDvrcMyocRUTAyEI4f0+bwU0kHMF8
         ysQ2C/b1vwuZV9czNufwZ4sx8/QEBpjBdXxubvF6nxARYTkbmLV8s4YWTMg0KaKq1tQ+
         iTB4WetOxCCGBpL2zh9u7fYV0WYvgYgEYzqcsec3To/pZcbNn0tWAtIi+xM3qh5raJ/b
         u2b7icNtz3ZPGbJK0KmveBclzmanZeN60v8fCBxHgjHwo9DkHYmAbmT3JjuIrtJ+TqM5
         EmcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXjgldndYk0CumQPZ0QyBr5bDpbA2cCFHF4W1rkpFNz/XPZkDj6
	ase4V4xEWAq1Rd6OJ32+VexvNEqAAxBWOnYWE0JUV+6WZA7lzAjHQPkdi/2P1DF5e0WimpdYQvg
	HOSmOPWYnWsCTOV8XHa49uv25k4WsX7LBf6Ne31MP7fRVvdiVPk/F4cl5F6esuW5W3A==
X-Received: by 2002:a63:610f:: with SMTP id v15mr48796876pgb.128.1557335238511;
        Wed, 08 May 2019 10:07:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMwj8vuKj90x89GRXhhm9AYADHOEfhT+z/gLmsfM7OMCAeU759ktOiZs+3cGR4QuyS6vB8
X-Received: by 2002:a63:610f:: with SMTP id v15mr48796793pgb.128.1557335237862;
        Wed, 08 May 2019 10:07:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557335237; cv=none;
        d=google.com; s=arc-20160816;
        b=vgGg9fy9FRjzUjaFF5zFT8fS32GrpjcXiZvWiYFVILMyWAvx89INowKfhhXiqkUwMv
         kDYM5dh7Yw3QO2Wuu4UYcmwR8m9nmFJCJHogHyY7VgGoFTkpS7rL4CPTl+8dW+oLkHTy
         xRn+KRLVfqZB79iUmNU60o9Z4TBZEZJJ8KHae0Pm6psnGHt/vgP17SfoSoQoZZZmgIOW
         Xu5QmhoBUHReYrOibGX1xR1ER5ICE3sWCmPfcDdgMKeD2RY4fZAjYQf+mCuGZ/y2UWCc
         /tNPCB4XPg8VSsrYt7QS8Cg2roMIYp5K3emeOXIeYNnOMaSNSSQE4eHztDaf55R5dmSq
         lK7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yMEWSrYrkBtNCnMGeX0baXrNh/pC/64KM+hIHnSkEPs=;
        b=uLHUKFqt1uRoC7lfTls3lBxRJFJ/rh1Q3+dj6iF1H+MJZKJHQN+5o/XKw6rm/EVqGd
         J3GwdV1LTJLtQIq7iYbb4lcWpGetsl4Jw53RJ8dAs74MklAopKDF94eb46vnDGbLRZfC
         sZsmR0+eAYiomLhsd150nkcm0Q97bHWb3F7ZoWLstcvsrWc8i03ZihXzwt9akjYUoWau
         ScBSIi3eyO56PGu77+bYURjLbC7mdcSmlB2bRfAzjja9jFsszOvUJHY8ioBpDe3s9JjQ
         LmITIfxohlXPv4Q91doB5u8CEoDabCGu3ydI9M32U3h8fSIGCzTMyf+tldws9eYbmjUs
         neiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h3si23864898pgg.83.2019.05.08.10.07.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 10:07:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 10:07:05 -0700
X-ExtLoop1: 1
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by orsmga003.jf.intel.com with ESMTP; 08 May 2019 10:07:04 -0700
Date: Wed, 8 May 2019 10:09:09 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 48/62] selftests/x86/mktme: Test the MKTME APIs
Message-ID: <20190508170909.GA1930@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-49-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-49-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Please ignore this patch.
It includes an outdated draft from early testing. Other than showing
our intent to deliver selftests, it is not out for review.

Alison

