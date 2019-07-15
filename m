Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A757FC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 09:02:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78E08214DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 09:02:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78E08214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 139516B0006; Mon, 15 Jul 2019 05:02:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C2576B0007; Mon, 15 Jul 2019 05:02:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7D256B0008; Mon, 15 Jul 2019 05:02:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF7336B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 05:02:54 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 21so9921824pfu.9
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 02:02:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=UVLBeDgqnnk2zrSJQPLKaBhSLPMHfwvqIYi69QP17ec=;
        b=WxQ5ClTdE2AWIrZz+ehDZW7jlmyjpgU7XnFtf85iDe45eguntxMFic9bJAERhBe//Z
         WF9/9O+0b5Zk85eX34ddf313yg5VuufCbYcSLfonnrU5HBpbeSKhrwiOjhY3och0DD96
         UCfr9VJ82RZrQEmDWxon1LNW/EVxWxEWC4/R13jYVBMPX/ZRNVQZ6RfsmodGaYsbrEcs
         gr1/2YzwrXZyMxIYYd6CMqQDFVbfeR2U8f/N4v8UkyrGE9wH/6V03C3kQ0VLWJaQDp5E
         aHJK7DEguWF6khXncH6uZcjhI3VfepVA0beBeWf8CiGQHIIHgnbGe3HLhQQ2sLIiZtKE
         mlXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWRLDrS8cygD6vDZKQsnN/sNf/Qx8FfVfDyIvDzhfU5Ijiu3NHR
	4V8/cK3/MAzO5wIuo8E95QLccm3f3TpeLyZ8vBS9VuAadktKLiwBkR/jj79xJyP+R/+fDAYng61
	+Gk/crRTKopwnxHheZ6YGMWcKswJ5sPCkvKrcnyKLzceftF23kTtQdOB66CAtZ+q0Rg==
X-Received: by 2002:a17:902:2f84:: with SMTP id t4mr21843916plb.57.1563181374279;
        Mon, 15 Jul 2019 02:02:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7ZRs9BoC+2zhcWzSyKz/1dnqbHiD98bUalgSa/4mUwvjoi+gdPBP9do7AloqWQAnqH9Wq
X-Received: by 2002:a17:902:2f84:: with SMTP id t4mr21843852plb.57.1563181373533;
        Mon, 15 Jul 2019 02:02:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563181373; cv=none;
        d=google.com; s=arc-20160816;
        b=Y5w/y/58V+solcsw2hj1LRjxTn0Ps6dda01WRli+Bo1RAO+pcDQbCmYcfX9CJ0AdEU
         yNXCGoLHfTZyKqyAeNpfNchi3aZ2UeM14VVEs4brqgxKlLUW0ai8wsaXmMjLu6SXPsfr
         Sh21gLYK39FIHRFm2Y5xY7ZvksfXFbHuwDdfZ5HBsOsuf47YlR1nI2MU6MSRp1rGVBrA
         S1CH86mjwA7vLqX5t+0FaEIum5P7RkXVz2Wjry2S1LnRo/X4dRPMKYo7gCPzfuAQUgA/
         m/47cBTrLQ/ZBWgbdXQgt5DvOhZTWo+8t7ZkBDzm2eD46+FpZz6vuK5bCNgiZgAN6b6W
         g0PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=UVLBeDgqnnk2zrSJQPLKaBhSLPMHfwvqIYi69QP17ec=;
        b=Lu+eIXdolAl9eehzuns4PrYhdwzOrrouATXXc3ndwCdfuniGZiiRrIAMMAt4ZVH01T
         wLcSqagufB97a74/TxksKYwNFgbcyvW9nNqlnGfL8DI8ZWdcaoJ8Aun59zTqYPfInyFz
         5gNos1hRy+7oWDib1C+w1D9od+sDNTb0E8yCupG9Wq4SMa5HEjd8n0+onWeHreTOm9Mo
         2wveT08ROS8+0OvInQPkQeU7thuFpE1aAZAQueCPgrcaLAPDLT4oSzb+xgt1mC7Q6a3+
         tNl/BuVBKaQXh62Csteg8YSKGpN4+js+WRxrEwCEWXnqLxWKxaDw78vslkSj07dqyj06
         WMvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id c1si15348610pld.418.2019.07.15.02.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 02:02:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Jul 2019 02:02:52 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,493,1557212400"; 
   d="scan'208";a="365809173"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 15 Jul 2019 02:02:48 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id DF2ED14B; Mon, 15 Jul 2019 12:02:47 +0300 (EEST)
Date: Mon, 15 Jul 2019 12:02:47 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Randy Dunlap <rdunlap@infradead.org>,
	Alison Schofield <alison.schofield@intel.com>
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
Subject: Re: [PATCH, RFC 57/62] x86/mktme: Overview of Multi-Key Total Memory
 Encryption
Message-ID: <20190715090247.lclzdru5gqowweis@black.fi.intel.com>
References:<20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-58-kirill.shutemov@linux.intel.com>
 <a2d2ac19-1dfe-6f85-df83-d72de4d5fcbf@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To:<a2d2ac19-1dfe-6f85-df83-d72de4d5fcbf@infradead.org>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 14, 2019 at 06:16:49PM +0000, Randy Dunlap wrote:
> On 5/8/19 7:44 AM, Kirill A. Shutemov wrote:
> > From: Alison Schofield <alison.schofield@intel.com>
> > 
> > Provide an overview of MKTME on Intel Platforms.
> > 
> > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  Documentation/x86/mktme/index.rst          |  8 +++
> >  Documentation/x86/mktme/mktme_overview.rst | 57 ++++++++++++++++++++++
> >  2 files changed, 65 insertions(+)
> >  create mode 100644 Documentation/x86/mktme/index.rst
> >  create mode 100644 Documentation/x86/mktme/mktme_overview.rst
> 
> 
> > diff --git a/Documentation/x86/mktme/mktme_overview.rst b/Documentation/x86/mktme/mktme_overview.rst
> > new file mode 100644
> > index 000000000000..59c023965554
> > --- /dev/null
> > +++ b/Documentation/x86/mktme/mktme_overview.rst
> > @@ -0,0 +1,57 @@
> > +Overview
> > +=========
> ...
> > +--
> > +1. https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf
> > +2. The MKTME architecture supports up to 16 bits of KeyIDs, so a
> > +   maximum of 65535 keys on top of the “TME key” at KeyID-0.  The
> > +   first implementation is expected to support 5 bits, making 63
> 
> Hi,
> How do 5 bits make 63 keys available?

Yep, typo. It has to be 6 bits.

Alison, please correct this.

-- 
 Kirill A. Shutemov

