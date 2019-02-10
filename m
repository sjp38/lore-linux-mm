Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7EF7C282C2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 22:29:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D0BE213F2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 22:29:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D0BE213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9DDB8E00A9; Sun, 10 Feb 2019 17:29:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B26048E0002; Sun, 10 Feb 2019 17:29:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C9728E00A9; Sun, 10 Feb 2019 17:29:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58EB98E0002
	for <linux-mm@kvack.org>; Sun, 10 Feb 2019 17:29:19 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id m3so8223179pfj.14
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 14:29:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Uc+6LWgflWAeGDIDSiK+nmlnirf3f2Iv2CkWMGRhv5c=;
        b=cxIA27kOwGdSk0znciQe/r5smQrFMNPR/PAij8u0LPXMsJfs3eHZmmHrQz4s6W8VhD
         g8EI8SgbvDirP5C0uTSp47o5jxRzsymFuZcc/o/+fkVMXzj8gwRXfkVABUwGoV+R91zq
         hLYSi5hmLVJ9SoUn9FJ77OKTDSOHOVvEm18Zb7va91/eUmaVlR+aZ9WlNHpF4+xc72rJ
         jOMjfeC62Uyx7W6+vbIljfXCSB0/JzspkVavD2hjPn/ubBEgpWswtBuRDfex75i4erTY
         5WkAVjms+O4LPTlHmZdgba6psdvyXXudP1tDYoL/mjjo8i3TqWdkaJXyvXL4UzrQmL6X
         Kxfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ9VG3MtFmw/JIb9SMcWQZxYfDR6fb3WTRZrUO+5/HYQNVi56Bk
	yEEw7tuad6cyZeBiQX/SYxh7GoBtoxVLztalIJldahJyrrSeNxQFCQl7sDZWbY19QSGY6VzAxHf
	0IEJ6zNTq1AA54nObjKlak4oGa8kikVgMOl8buQmNf+9ytasOB4rOKwYlcB+KnUilGA==
X-Received: by 2002:a62:5f07:: with SMTP id t7mr33599969pfb.108.1549837758757;
        Sun, 10 Feb 2019 14:29:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iast02BsxL5ZYEOAbKBbLTm5a/Ap1tCgmzHGUkBQZU0t57JEOFNYrYu/y/qOzxqfc1CoHoA
X-Received: by 2002:a62:5f07:: with SMTP id t7mr33599933pfb.108.1549837757880;
        Sun, 10 Feb 2019 14:29:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549837757; cv=none;
        d=google.com; s=arc-20160816;
        b=mntxwx/pRuvnFBW/FrTGQmWLZYrY3V3i2TnCXtE35P+Pu1flDDilaDKqTFU95mvH2J
         n/bSdZvkhYE6JIjSgzWSyy3Rjnh6qUE4XIl3zgFbeJIS6ZbPJ3sw/7/LPpEptB7HQ1N5
         85W4O9454sUK9UbkMOsYaRJzQYrf1WJNRPvxc9Z1ZCzbdx8jZ3GoVi6YTPi5fMg/IcIp
         Ntz99cD6kcGRAuAaVDSctVj6E4TVi59hdWDprkk1Qjkjfr4CsHW4u7DdUyhlHkZDZhZg
         6BagR/9owNPWCAy3mai3lavNLHAPi/l9B1yau4XCCXNA5BWjcxqRFIbd3hLCUSmANLQh
         QU1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Uc+6LWgflWAeGDIDSiK+nmlnirf3f2Iv2CkWMGRhv5c=;
        b=yvOxWuuMHVFPTYEnov6iJ18Ri++a3SCgUZPRbeNPDVfkcuBdd3Adakiyk1eARq84F2
         pN51f8m1VPHenP7HKV13z9U/W72wmuZl7V7T/yViFCmsWwIIWLQ53wYxqAS+H+tey/mG
         bDWc4U2MBULFZWazPWEiODv4y5O7PRsJ+h61wJtxEav+HwbqBTLwUFSkgjRmOeumgF7c
         2l/oZ0xRYlp6QGAnvH3gKAUZHWZ88sdVy3KD+nZvX9taBj4820P4/Laj1mORuZQx06dM
         tIoZweJl4ARD/qbXZwElYurxdd77lpD1IhRNCecsU5PkXwZ5NSXGCblJohhllqKVmre4
         1Q2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id a1si7567760pgw.142.2019.02.10.14.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 14:29:17 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Feb 2019 14:29:16 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,356,1544515200"; 
   d="scan'208";a="125412173"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 10 Feb 2019 14:29:15 -0800
Date: Sun, 10 Feb 2019 14:29:03 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm/gup.c: Remove unused write variable
Message-ID: <20190210222902.GA13720@iweiny-DESK2.sc.intel.com>
References: <20190209173109.9361-1-ira.weiny@intel.com>
 <alpine.DEB.2.21.1902102029560.8784@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1902102029560.8784@nanos.tec.linutronix.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 10, 2019 at 08:39:44PM +0100, Thomas Gleixner wrote:
> Ira,
> 
> On Sat, 9 Feb 2019, ira.weiny@intel.com wrote:
> 
> nice patch. Just a few nitpicks vs. the subject and the change log.
> 
> > Subject: [PATCH] mm/gup.c: Remove unused write variable
> 
> We usually avoid filenames in the subsystem prefix. mm/gup: is sufficient.

Thanks.

> 
> But what's a bit more confusing is 'write variable'. You are not removing a
> variable, you are removing a unused function argument. That's two different
> things.

Indeed my mistake.

> 
> > write is unused in gup_fast_permitted so remove it.
> 
> When referencing functions please use brackets so it's clear that you talk
> about a function, i.e. gup_fast_permitted().
> 
> So the correct subject line would be:
> 
>   Subject: [PATCH] mm/gup: Remove write argument from gup_fast_permitted()

NP, V2 on its way,
Ira

> 
> Thanks,
> 
> 	tglx

