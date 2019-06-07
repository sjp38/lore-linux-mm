Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96DEDC468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:31:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 590E22133D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:31:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 590E22133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E09906B026B; Fri,  7 Jun 2019 12:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB98B6B026E; Fri,  7 Jun 2019 12:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA9436B026F; Fri,  7 Jun 2019 12:31:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94DE46B026B
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:31:46 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j7so1838210pfn.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:31:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=i6gPtKa21V7fgo0pFXUO7mMvi7LOZQA2rvkWN6EKcuQ=;
        b=QYufdNTwHEUsWKmEVqffIem4XfPNs0iCRD6cfOcGRH4U3/scdf3vcPw1uIJnrtu66R
         R0+OvnWXh/kZNhSP5a9X/zVwFIhgvkk2Gtr+7UUItkgP8DlYqIVN9txCPpRpucH31IYD
         lfakfsHnqug7UitTEugNS/K0RYzrOBtDRUkZ5zQKa2wTYMKsIgsGctVEsed77aeAWssc
         Mgc2RFomf7q6P9Kk7FlE7k+WSt12mkaFi0Fb3ewoBQJbl+d3sSABsfZGNM8lWzW3dCMX
         XMey4pnjdpofELuij7YmfSiJL73IBLo9tO+f0d8MmVShN7kTB2tQM78NtumT2s4rGJBG
         Gyag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAViQWbmtf16hdVrSCOv0tXSZ62a/iVWb2qorwFUoX1Ehx6J9sEm
	yN1c56BUY33bdw2VrkECKtoBXvra+LmvkZzoZbcOblNsP6HaPUdlBLf55sbQalZioMpJ8goWnNh
	xOMWReMv/ooBoqQ4r7VcTcnYoRF/lFEFnXSokw5Wwmi594eEQYxsNWYE7LddlBez26A==
X-Received: by 2002:a65:4786:: with SMTP id e6mr3626050pgs.85.1559925106172;
        Fri, 07 Jun 2019 09:31:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXsCT8qTdhzFioIYiHhG4Fg19sG9G0Tb6ihso4yGyLgKjjAI0JpMHs1kw37fownoDfRcoz
X-Received: by 2002:a65:4786:: with SMTP id e6mr3625973pgs.85.1559925105482;
        Fri, 07 Jun 2019 09:31:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559925105; cv=none;
        d=google.com; s=arc-20160816;
        b=gEWxF+tyZePxu7UhisiJ0OTGFZwlU5bWbNefp3fnUQeelWzS5rzUWdYLmraQhzm9uI
         CTg4zr2XzfaN/8AmShe0DLk2zf2OwLkHFybHsHwShjMuGNq6HCICjIewRePVQfFhe9nr
         wdF+HbqCqDTWxR+DzpPwpRa7n+kBPt2KKl9FuYQFpY6CbbZHxcNMqBf9GXfmd46dCDjs
         /sF4mBCXZ0JZagmmzkzDRFhd/eXNowi/LArFLy/zIBrv6Gr3JSV7Nxqk7KBLVxeCj0Kl
         joj0vHPUm3zE6rggsjP77AY1ZLe21QWjUbfbKbK7XtWRVhBzUfkskXVyiNCX4kyPnqN+
         V7Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=i6gPtKa21V7fgo0pFXUO7mMvi7LOZQA2rvkWN6EKcuQ=;
        b=M3a3kvZ2Q7JfR17FsWVzaeON8gHohjvOUuKVLEvtX0SfVakzB+EaTlDx/QIymfRrto
         IuZokFNm5RXvXYpXFxyg8A7M9Pk8nV3D/ObOoSaNEn/EV0PaJkLA+buqCg7+xTuoUZ+J
         enWr1+KdyxOoUTThPQh1N3DIpdeeyHy5u7f/4N6W7eHXRPHB/iZQsp/o6m55kIxUJy2J
         Xq/dq106nw9+SizggM/XXU6Uiu97NMA6NxMQVuQ1LC6QiSScEvuo5p4nusr5e1NxEFgu
         yw/diIPPUfwT4aL4smnuhK4n8mRhxrN2txuRcFCyYctdeIxloEVGkTgnS81J7rU6aMHT
         sDQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h1si2266261pgv.67.2019.06.07.09.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 09:31:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 09:31:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,563,1557212400"; 
   d="scan'208";a="182722617"
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga002.fm.intel.com with ESMTP; 07 Jun 2019 09:31:44 -0700
Message-ID: <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>, Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,  Pavel Machek
 <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar"
 <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Fri, 07 Jun 2019 09:23:43 -0700
In-Reply-To: <20190607080832.GT3419@hirez.programming.kicks-ass.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 10:08 +0200, Peter Zijlstra wrote:
> On Thu, Jun 06, 2019 at 01:09:15PM -0700, Yu-cheng Yu wrote:
> > Indirect Branch Tracking (IBT) provides an optional legacy code bitmap
> > that allows execution of legacy, non-IBT compatible library by an
> > IBT-enabled application.  When set, each bit in the bitmap indicates
> > one page of legacy code.
> > 
> > The bitmap is allocated and setup from the application.
> > +int cet_setup_ibt_bitmap(unsigned long bitmap, unsigned long size)
> > +{
> > +	u64 r;
> > +
> > +	if (!current->thread.cet.ibt_enabled)
> > +		return -EINVAL;
> > +
> > +	if (!PAGE_ALIGNED(bitmap) || (size > TASK_SIZE_MAX))
> > +		return -EINVAL;
> > +
> > +	current->thread.cet.ibt_bitmap_addr = bitmap;
> > +	current->thread.cet.ibt_bitmap_size = size;
> > +
> > +	/*
> > +	 * Turn on IBT legacy bitmap.
> > +	 */
> > +	modify_fpu_regs_begin();
> > +	rdmsrl(MSR_IA32_U_CET, r);
> > +	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> > +	wrmsrl(MSR_IA32_U_CET, r);
> > +	modify_fpu_regs_end();
> > +
> > +	return 0;
> > +}
> 
> So you just program a random user supplied address into the hardware.
> What happens if there's not actually anything at that address or the
> user munmap()s the data after doing this?

This function checks the bitmap's alignment and size, and anything else is the
app's responsibility.  What else do you think the kernel should check?

Yu-cheng

