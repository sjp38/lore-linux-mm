Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3D29C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:27:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E0322133F
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:27:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E0322133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E95806B0007; Mon, 13 May 2019 10:27:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6D516B000A; Mon, 13 May 2019 10:27:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D80B36B000C; Mon, 13 May 2019 10:27:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A07486B0007
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:27:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so9331359pgc.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:27:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lJN4mUylA7pJ81RGeS4qrXuQIV8D5ogZ6ATvIl89jW0=;
        b=R75BJqbDvuvFDKSa8oKxkRacSxd11SNTvfiqAxwIQF6a0Qu6Z/x/Fjyl2YClD6d9N2
         SZNkUP1tO3cEBeMVCBBLBeq5CDj5sOBTKk6O+zw7csaO//XInxrDOA6mKi9pNWiL85gw
         nHkb850UrMBsVcG/VOVlG8K4TvgK3pPF9WUUwpUB5/OAwyUNxvmZ13egVGB0Ebas9VO0
         KKpqevFCJLglVv+3ne+yGM9oRnRjFqlsXR9eA8DGpBHygi0iSwMGwkFQIX1/z/dyDsLS
         CL76ssJVqGlhulWXI3cbTGJiBdfVBm4f4Q5FxjPIcWR1nbadXqPXAFGEboq/vhtpvp3a
         YV7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVzuoIbH47taoQaGIDyGzUEYKJ655FzyowbdjwpiBlCiRrjZKIy
	0r56wdFD7BlAz7G6b7jjaDmnaZ3MRQaLieU7IF6cvNVTrRyElQxcWt1Qp0IiYaQ2+165a7+XhQe
	+Q667zu0STQ82OOMq0EucN5WxlVGvvpF0OcDdoc+deAlzGg/C5W+g9/U/Hx4C8Ljd6Q==
X-Received: by 2002:a63:6647:: with SMTP id a68mr15808716pgc.292.1557757665188;
        Mon, 13 May 2019 07:27:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+HNGN2+OsuNOqdOYIBFTom48kKQqCHj00vBH0ofwAvIvymczmq4dO+nIQm1v9kWufZ4W2
X-Received: by 2002:a63:6647:: with SMTP id a68mr15808641pgc.292.1557757664571;
        Mon, 13 May 2019 07:27:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557757664; cv=none;
        d=google.com; s=arc-20160816;
        b=X2MJKshDA+DRuFZcMyEXy/AdJnHBuedjOCp+D//vfBdYSH4rH0VBfdYrFGGaXgt+UF
         D3dY3vaPapi2uSr5AdADTBSThl+VUhqIPDI44LxO/IJdQEtQCWC9PxdvrshHf5HO+gdx
         ZOdTAOQGnrJYla0oECwynHT4NVtPsmBK6DxfAOkvn/tQPU822z1kgChb2dUFndGn0QRW
         2jx4fYjPgspWm0o3mMkx5e99RyojIeagJnjUTVUIfEpatPzATvxbYIoqLj5LY8L+7OEN
         l3Ni1M93xTKgcXSpUEYfWgcxvpv8D/eRSG10Nkiu+qd9qRwxbpx6fRFUx8g5AEBQcBfw
         jUxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lJN4mUylA7pJ81RGeS4qrXuQIV8D5ogZ6ATvIl89jW0=;
        b=E81Tz9cDymHPFwO4Ys9GlMcOY+NXBMdkf8jTD0aat0zz5XjJ2AWJYZ7dDuwYPAr5sk
         CvHkFXkozsKYd7DTD6uQ9Adhi0xNP7CnY1lK/GVzviOMj/N2xB7cBvH0pJeUyBXn1aiH
         7sxawyu4F0JMY7CLPgJqGXhK1dJ6Z6rjJhFg2XpX/NBSuW3X6bF9R0IIWbUdqKeGCu8U
         3gDPYEOXzPzyV/XUWSJfdP/0PReOmTwyFTAQ04texAJHxA5a6Ms+m637N+fUKumG4AKX
         pvyd7Qbu/coVPLEGSvc48X3+WL/e0mePVuvSSgzkbRl06hmSV1mQZADws21p4e8XQM18
         hPiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id a69si3320006pla.178.2019.05.13.07.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:27:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 May 2019 07:27:43 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 13 May 2019 07:27:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 489FE2B1; Mon, 13 May 2019 17:27:39 +0300 (EEST)
Date: Mon, 13 May 2019 17:27:39 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 03/62] mm/ksm: Do not merge pages with different
 KeyIDs
Message-ID: <20190513142739.7v3cnrnnnsdldcuc@black.fi.intel.com>
References:<20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-4-kirill.shutemov@linux.intel.com>
 <1697adad-6ae2-ea85-bab5-0144929ed2d9@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<1697adad-6ae2-ea85-bab5-0144929ed2d9@intel.com>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 06:07:11PM +0000, Dave Hansen wrote:
> On 5/8/19 7:43 AM, Kirill A. Shutemov wrote:
> > KeyID indicates what key to use to encrypt and decrypt page's content.
> > Depending on the implementation a cipher text may be tied to physical
> > address of the page. It means that pages with an identical plain text
> > would appear different if KSM would look at a cipher text. It effectively
> > disables KSM for encrypted pages.
> > 
> > In addition, some implementations may not allow to read cipher text at all.
> > 
> > KSM compares plain text instead (transparently to KSM code).
> > 
> > But we still need to make sure that pages with identical plain text will
> > not be merged together if they are encrypted with different keys.
> > 
> > To make it work kernel only allows merging pages with the same KeyID.
> > The approach guarantees that the merged page can be read by all users.
> 
> I can't really parse this description.  Can I suggest replacement text?

Sure.

-- 
 Kirill A. Shutemov

