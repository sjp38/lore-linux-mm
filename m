Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 310A0C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 19:46:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8EC92082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 19:46:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8EC92082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D3416B026A; Mon, 10 Jun 2019 15:46:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 783E96B026B; Mon, 10 Jun 2019 15:46:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64DC16B026C; Mon, 10 Jun 2019 15:46:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 304AB6B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:46:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so7848608pfo.22
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:46:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wtwmfVjo6sqmcTv2XiIOpR0ULvdXqV88MnBl7t0X4IE=;
        b=lpM+eJ89As/tBIPyLjSFnzNNvAv835qIo4IoU7Mplpu+A0aK7vaQ0EhCEDU/qLS5Ba
         vEqOHR6EGc2TUZDKdRF6w4dX5dlBwnme7dP7Dx0aoUyyEJ4adGSRo7U0XTiFUbHog0v/
         nNbxRRlrk3y/zidIduFQLA6lTPIdXo0hFKTfMszrFVrRhKd75yC5UiPoN/9tXdWYoxI4
         F6NBgcZpvUsSb9vphbt1sXmiX2dxU5gI65TpXHB14bVXUVgzhnqtHt4uQT1/gGfgEvgV
         cSGvoTo1vpMZXMuOCLpJYydfdUhd+x0Dm0YrmrxitGW7EuelTo2mSOnnISt3/g4VFRnH
         zrAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU5LUZBlb/kpxJFxvmFQjrJ4ePv/9gKHPyxSNQP0EQoPKX6NwQX
	7UMOcDQZX7zKtrqfqwI4q8hWlpeHxEAWQwBR1eEp2k3f2NPQCtDDKQOyrRc0fczQVIugRXm8Kt9
	QAeg0W4eklEeW5ctx6MM9ZAdMrubDG28M08arqJb5yfdc960RxJfc8JvSeFsgCp0/1g==
X-Received: by 2002:a17:90a:bd10:: with SMTP id y16mr22486440pjr.92.1560195978846;
        Mon, 10 Jun 2019 12:46:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3RTobdcpBT3fng7+mSu5GTim3m/e9z7LbRsbYZzLT+77eIatJF6mKaYQ0+N7v+wVrswBu
X-Received: by 2002:a17:90a:bd10:: with SMTP id y16mr22486358pjr.92.1560195977833;
        Mon, 10 Jun 2019 12:46:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560195977; cv=none;
        d=google.com; s=arc-20160816;
        b=Xja4Qpel94fe/3j2sIetASECflEjJMpIUnC8HTFskj/k1e8M+FHR+UMXJBfsg7Ekbd
         sUdfKft3xBeq39wYo8yZulqlD87HkWLMAcSBiNrUlvcl+dV2rxWJGGvZhrpjHcfgo6Ku
         voeeo2gpvqQZ2eBaLgW1wlk5OSV71CJAHmDSXGbqoC+VMsmeOetXn5Y+hvSqMkdHVd63
         LdX/KKYnJ+Mg851NGYccUkr1uQdfUIviQx2jDa4JZm+pDZJURnvtsg+Y9v3O33Lpjy1R
         a4pPjk+45h4UXhKt8CHSlHyGlLqWvjGprgUqK0/zdey4+iusRXtBGmTtMZqz/bJ0IeqH
         dl9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=wtwmfVjo6sqmcTv2XiIOpR0ULvdXqV88MnBl7t0X4IE=;
        b=LBWWG3ItXmurtQUZIEsnJ5VH5vCCBQIt5TXERdXd0eUPh6CU6okKYWqmhNJDnyKCOV
         Ui5ZxhahhJ0xRrr+1vXUA5Q+BeO9ME0hIC/xk62V0hLCZ0emYzt2XFbPXG2DHgbEE+Nh
         PLTBf+y7vKc0pbBbD+u8Y1xbvslvMLwlxbM/qEXjU4nN1lerENJla8kboTJAQkSN0yzD
         cEiESNHgNGm177zhsZnwe4tjEy5I151EBGlq+a+yF7hv79QCX4gYCRBtMrUmu0Jfd8WJ
         Qng4oq+l4yZP8dInm6cVbWGEYWqK2ulawSQYlOlUn7xDDNBqdXP1IjtAK3VbssFUK2Xt
         EiTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u12si9740119pfh.256.2019.06.10.12.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 12:46:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 12:46:17 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 10 Jun 2019 12:46:15 -0700
Message-ID: <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
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
Date: Mon, 10 Jun 2019 12:38:09 -0700
In-Reply-To: <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
	 <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
	 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-10 at 11:02 -0700, Dave Hansen wrote:
> On 6/10/19 8:22 AM, Yu-cheng Yu wrote:
> > > How does glibc know the linear address space size?  We don’t want LA64 to
> > > break old binaries because the address calculation changed.
> > 
> > When an application starts, its highest stack address is determined.
> > It uses that as the maximum the bitmap needs to cover.
> 
> Huh, I didn't think we ran code from the stack. ;)
> 
> Especially given the way that we implemented the new 5-level-paging
> address space, I don't think that expecting code to be below the stack
> is a good universal expectation.

Yes, you make a good point.  However, allowing the application manage the bitmap
is the most efficient and flexible.  If the loader finds a legacy lib is beyond
the bitmap can cover, it can deal with the problem by moving the lib to a lower
address; or re-allocate the bitmap.  If the loader cannot allocate a big bitmap
to cover all 5-level address space (the bitmap will be large), it can put all
legacy lib's at lower address.  We cannot do these easily in the kernel.

Yu-cheng

