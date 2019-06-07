Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41856C468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:14:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07466212F5
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:14:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07466212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A05816B026B; Fri,  7 Jun 2019 16:14:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98E786B026C; Fri,  7 Jun 2019 16:14:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 856AD6B026E; Fri,  7 Jun 2019 16:14:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4888B6B026B
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:14:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w14so2051267plp.4
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:14:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AdroJ+jjl9mLSvX2fCDMcD9Uq4Wl0tRfoxZHbjn62X4=;
        b=JWLreHy/sClOweJlQslUr71NhoynhZLhuOBcOfX6OX5adeAYiJLstN7n4kwkK4rerE
         B21Bbis/uI87uKX6mB9hK54h84ptJM3CBp754+naSh+I5P2euggvwfEeW/yxVPNCfJup
         wkPjZZl1iE9lSZ/RaIRoc34xxTgYUgXP2HC9PnVE4NzZFHXSiEKsoQxrhzDD4sPCfuqD
         Ys3+PSGuQzw3ZKH18jf7s8MpKQ7d+PVuXo7J4wbUhjWkhlSaZ56SqVWOCnKr7+ss5v76
         UWe4nIMqjJSmXsCSx/CJQysJ8RgPLXGWu9RQ/z5YdNBcAJVwFt5y8Zf/u0TmnkIQFXc0
         j0sQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXrQr7MLQ3+UxcK4XsMwFlDqq0AkiqHdzrtQEs0QUNsL68znK6l
	j14HhbApa5Kh6/b93PCwWoD5aE4Hq6rb1bS96TXcmcJPxcEgU2V+8t3xziuN02yKE7AGEJGgC1L
	YlhN1Ym0LJDBD6fYbtg5ASxeOHPgeoQo8CXCPid8i/u/VaoQY+TboLWeZ+uuUlLWLCg==
X-Received: by 2002:a63:2c50:: with SMTP id s77mr4562176pgs.175.1559938454885;
        Fri, 07 Jun 2019 13:14:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKo8xm8qCh0kir5X2hCgD+7xX7pUBnwILyb9wsBG41lRVn9rq+Ih6ri1eguA40qndxE+LC
X-Received: by 2002:a63:2c50:: with SMTP id s77mr4562150pgs.175.1559938454179;
        Fri, 07 Jun 2019 13:14:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559938454; cv=none;
        d=google.com; s=arc-20160816;
        b=HGZFBRLtqYfyk+YPs/RPLhqOWx03+JR1LHmDvRaNBsFPKGDxjb5yALFqh0TnFzvoG8
         R1kjVuvevU/bPBAQ1V1WcKZ1iBqzxYYgnErKvz7VbHQl/5nRxLM76NGyn1GFnW/XzVaO
         HM998FgGFmIvTsI/RgkGZGJSTdW5SrUb9hg3ecGURgmTGtOZxIvPCD92PUWZaZpZ+/AI
         MGd8ZaexRaSv9x77ogfshAfUmo11phpEsTY12RfCmyJshEhiGXZ77VmfkL1gK1bzcWuy
         lAQZnzsNo0rQR+w2uXkd/wQnoqJdDifxsNh3bqQq7EcqqdeU5GR4GfewsOpoPctR6G27
         XG/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=AdroJ+jjl9mLSvX2fCDMcD9Uq4Wl0tRfoxZHbjn62X4=;
        b=mih6Zs+iAwrP2taMLmEG+6X/i4AsfqmOaUZQYdCF2VDr7Suk/EqyIQztUVHuCE9Pm5
         kUc5YDYtCnwiBuA6ACa8h2vFBRlI91SP+rN1QqfQs9TCslYbwCN4LGMG0jQYeX4p7fMV
         GQlSrZ23lXaWYft1+6b8Jr6vfgmVMndseC8EzE+9QYxQFZQLdf3c+Jh5ZFMx/Rc/9kPt
         8Hm+CaKDxwPo6b3uANBB4nBrcCcX1uBL6tCJNJQtvRqPq01Zfj8eEV+GbeihpeKHOKUg
         wZvzcUaEGhPdyj4Jg/bV93yEmYTWHWdo4CZ1Q0112Op9dXVl6YiePxyDwUn0wA6NIY7N
         cseg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 33si3196230ply.10.2019.06.07.13.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:14:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 13:14:13 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 07 Jun 2019 13:14:12 -0700
Message-ID: <0e505563f7dae3849b57fb327f578f41b760b6f7.camel@intel.com>
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
Date: Fri, 07 Jun 2019 13:06:10 -0700
In-Reply-To: <4b448cde-ee4e-1c95-0f7f-4fe694be7db6@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <4b448cde-ee4e-1c95-0f7f-4fe694be7db6@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 13:00 -0700, Dave Hansen wrote:
> On 6/7/19 12:49 PM, Yu-cheng Yu wrote:
> > > 
> > > This also gives us an excellent opportunity to make it read-only as seen
> > > from
> > > userspace to prevent exploits from just poking it full of ones before
> > > redirecting execution.
> > 
> > GLIBC sets bits only for legacy code, and then makes the bitmap read-
> > only.  That
> > avoids most issues:
> > 
> >   To populate bitmap pages, mprotect() is required.
> >   Reading zero bitmap pages would not waste more physical memory, right?
> 
> Huh, how does glibc know about all possible past and future legacy code
> in the application?

When dlopen() gets a legacy binary and the policy allows that, it will manage
the bitmap:

  If a bitmap has not been created, create one.
  Set bits for the legacy code being loaded.

Yu-cheng

