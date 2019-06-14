Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9687C31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 21:42:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4898217F9
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 21:42:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4898217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 459316B0006; Fri, 14 Jun 2019 17:42:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40A746B0007; Fri, 14 Jun 2019 17:42:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2855B6B0008; Fri, 14 Jun 2019 17:42:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E25E16B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 17:42:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b24so2318076plz.20
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:42:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YGBFNzaJ28o9dvXmTGj1pU7yex9BAymk63JbfISxgbE=;
        b=ZQGBA181Ot4Zonr/BaTdqDSJ9jk2Th6ONfKJc/box+A1AZeiOKFpktUoqUSvGqizAV
         v3N6AITS/sjXAkZCpuRlt6LbCnYe0ML1dzDMtBkJ+BteryZcpXY/hi/NoUPOyDZW71De
         2ibkwER5VzLvMbzCNE/D0lvrwP7o6p5colR5c5g6ZzU2wpYctS2Jn7XYdvf5jHj0lwf0
         1UxczxUJu+VGd+SoXlpjhEioxNe28Bj2fhDP1/anLy5g5j3A5r4SRju0wEErPty8niLV
         BSatdKqPfwTIpJc69HOGBE2hOor7enFg25WRXsdiwHzzwzUGHg6RDcDROskVt/B55/t8
         EFHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV4EWq3sahRcAuHYGfGHnfILDFxcmq2RGO2cNmsu6UdEh5k8cNC
	fLZQwgfrTxhsIMXtmnge+FIi7NQzxsBDJ4tCAxxV61gZseBmA7FceSinf3Hiy6vbYXWqYTOc2+c
	yMvvT8m2VhvK0lDyZ599yLgfCKrcLoWDuZ8rp+L1nvLOVqg34yzZH0NjSd39jXwihIw==
X-Received: by 2002:a17:902:7581:: with SMTP id j1mr94900165pll.23.1560548537580;
        Fri, 14 Jun 2019 14:42:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytJLh7S5iaoLfSP8D1/eeDNmiJGy0jkx0ubkloeP1J6n34UHSXsRTwLorg9t/o5tWAiugw
X-Received: by 2002:a17:902:7581:: with SMTP id j1mr94900123pll.23.1560548536675;
        Fri, 14 Jun 2019 14:42:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560548536; cv=none;
        d=google.com; s=arc-20160816;
        b=F0kmLiVN0lRb8Fm8hKc4vCOgnAr4XQkY4nDvSZW1WbcTgRgCZwhDd2fOKL39RTXkc6
         ebZ7adREaIy2fRRKplMLRamwxeEOYSqygm1hB6jYVPMELL3TvBUrejysb6Wcoaihn1JK
         2gPh+E6qrCiPuYgMj6KkQ10yBeTDvIKfARgafYncWdY6bbozqYELftZi9bVlYYDZ8tnI
         bDBbyecWq0njdYolFtESVEZ5UeACNOzFzf2Fi+G+tUOHv8sQNoJteyhO5+pM03M1/43l
         LfQYu3o2XIpI88G31kKVkBpF1w2qp3/Ot5QcWYYA0a+S5ICawn7Bwsf+IXii94hsVVc+
         l+pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=YGBFNzaJ28o9dvXmTGj1pU7yex9BAymk63JbfISxgbE=;
        b=HnJq3FHgY7dRF0/5rBtApjtp+HxoLXCXQiNC3etGaNIP/DChqBUuiKyNDaQB/uFwiM
         K89fh8teSwPmgweNu+C9DkMtdBw5Tb2SuwOu/5nVn0/3jtBaNslpNSEXym+hTwinOb2A
         lRq7uPgGGgK1XYske4pXQwCdc3dKjXBvFAicXSqw6x8WqPy7zhmMimxYO+jss4/y75aR
         r2Lbz/UWhrVQaAzcFlExhAP5eBrPaCWUKvd3brBR1EONHt3zyRKYm3VNNcdb4k0Hisfx
         Ry6PMVHitdbSLhFPevJnw9zWpQt5YG7j5yGJjujP07aB/4oVjvYFu10ub8iKd+8Hx1Vz
         0hCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y14si1552568pfr.82.2019.06.14.14.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 14:42:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 14:42:16 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga007.jf.intel.com with ESMTP; 14 Jun 2019 14:42:14 -0700
Message-ID: <359e6f64d646d5305c52f393db5296c469630d11.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski
 <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
 <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene
 Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin
 <Dave.Martin@arm.com>
Date: Fri, 14 Jun 2019 14:34:12 -0700
In-Reply-To: <598edca7-c36a-a236-3b72-08b2194eb609@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
	 <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
	 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com>
	 <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
	 <0665416d-9999-b394-df17-f2a5e1408130@intel.com>
	 <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
	 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com>
	 <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
	 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com>
	 <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
	 <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
	 <cf0d1470e95e0a8b88742651d06601a53d6655c1.camel@intel.com>
	 <5ddf59e2-c701-3741-eaa1-f63ee741ea55@intel.com>
	 <b5a915602020a6ce26ea1254f7f60e239c91bc9f.camel@intel.com>
	 <598edca7-c36a-a236-3b72-08b2194eb609@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-14 at 13:57 -0700, Dave Hansen wrote:
> On 6/14/19 10:13 AM, Yu-cheng Yu wrote:
> > On Fri, 2019-06-14 at 09:13 -0700, Dave Hansen wrote:
> > > On 6/14/19 8:25 AM, Yu-cheng Yu wrote:
> > > > The bitmap is very big.
> > > 
> > > Really?  It's actually, what, 8*4096=32k, so 1/32,768th of the size of
> > > the libraries legacy libraries you load?  Do our crash dumps really not
> > > know how to represent or deal with sparse mappings?
> > 
> > Ok, even the core dump is not physically big, its size still looks odd,
> > right?
> 
> Hell if I know.
> 
> Could you please go try this in practice so that we're designing this
> thing fixing real actual problems instead of phantoms that we're
> anticipating?
> 
> > Could this also affect how much time for GDB to load it.
> 
> I don't know.  Can you go find out for sure, please?

OK!

> 
> > I have a related question:
> > 
> > Do we allow the application to read the bitmap, or any fault from the
> > application on bitmap pages?
> 
> We have to allow apps to read it.  Otherwise they can't execute
> instructions.

What I meant was, if an app executes some legacy code that results in bitmap
lookup, but the bitmap page is not yet populated, and if we then populate that
page with all-zero, a #CP should follow.  So do we even populate that zero page
at all?

I think we should; a #CP is more obvious to the user at least.

> 
> We don't have to allow them to (popuating) fault on it.  But, if we
> don't, we need some kind of kernel interface to avoid the faults.

The plan is:

* Move STACK_TOP (and vdso) down to give space to the bitmap.

* Reserve the bitmap space from (mm->start_stack + PAGE_SIZE) to cover a code
size of TASK_SIZE_LOW, which is (TASK_SIZE_LOW / PAGE_SIZE / 8).

* Mmap the space only when the app issues the first mark-legacy prctl.  This
avoids the core-dump issue for most apps and the accounting problem that
MAP_NORESERVE probably won't solve completely.

* The bitmap is read-only.  The kernel sets the bitmap with
get_user_pages_fast(FOLL_WRITE) and user_access_begin()/user_addess_end().

I will send out a RFC patch.

Yu-cheng

