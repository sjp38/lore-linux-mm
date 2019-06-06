Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 931C2C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 525FF2064A
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:06:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="W6owKkia"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 525FF2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E387D6B02EF; Thu,  6 Jun 2019 18:06:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE8386B02F0; Thu,  6 Jun 2019 18:06:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFF1A6B02F1; Thu,  6 Jun 2019 18:06:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id A9B726B02EF
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:06:40 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x23so11183otp.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:06:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EIr4OnOI1xF9wai5ier5nmSpwnMBcVJFFbPwhyrlfw8=;
        b=Y5S61mBn6LDgTCSnOUout25m41fsI6z7EWx8hxa56/mOka1T0+qpMwPlGe1JUtZEuU
         +uzwns+XZEkJk48vojlhbalLLG85rNkhjlJ0p554ipOVd+qrclLOkIGX7VblARlGjDHE
         KeiLjVKfalf+eOvIAOf6X3yb6g+JL9phiU38ySf8wIh1vIWs3s6LO3/8BIlOaVbsPpNz
         6ndTtPwpi5etrB0NGzv8/6/D8r4m5CEyW+yNx9l4dUUvpGfLxecE68qUHKKPCgLBH9ul
         f6MYbnqRBa3XAd4YSAwWNq5dxkGmyJZyhEUB1+FL1WX+5gXlIF9a5wjt5ku80yGnu/Hf
         pu+A==
X-Gm-Message-State: APjAAAW3GjW6AeJFdBbsuUXz23nT8Rt7BiA/9kYPKVh6JpyxagkT8LYf
	rBR06HQOXXldyGp/oHdR2qP4Uve+2QCd0wMK+Ihh6/N5jHdi/0WKk0XpUDLmhwwh9G5O4tUXwEq
	be9B0ZVL9q8EbYS9cMMP02wy0FdoMiJAN4Ou+5RYTkbmwZ+miBY//bnKeeGaikxEmBw==
X-Received: by 2002:a9d:529:: with SMTP id 38mr16956303otw.145.1559858800314;
        Thu, 06 Jun 2019 15:06:40 -0700 (PDT)
X-Received: by 2002:a9d:529:: with SMTP id 38mr16956238otw.145.1559858799118;
        Thu, 06 Jun 2019 15:06:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559858799; cv=none;
        d=google.com; s=arc-20160816;
        b=BS87zaFar4gGR64LgMmv/T2T/baWPlJ/nvVmS6PrataLOGA4UtFWWftdVdZ06xkmyo
         q2REJfZ7/BOoZYKzqU+srP813rNRk/Kmxnm8dyUGXunMRAe0ePv/8j5Y9XOj+7LqK6WX
         wbck47MLlTw/0WO5pAr2zFR+tE6Gxqve95mDJmpP8f+MNERPRwBXqJpdTDqk3B1h2DgV
         U8aCv4nhohGhFh9FY74x5LXrs875xVqNSKgvdKbgTq4lQmCeewJRSVG8VBncwgYm61mG
         /y8RGPqeQ4ZmNwZ+ADDimFesSRkoY0XJ2Se2nMjRa11u9fZhRUYLTaCWfSZAB2+JESKR
         5RRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EIr4OnOI1xF9wai5ier5nmSpwnMBcVJFFbPwhyrlfw8=;
        b=UlJr5UhUmZzfg2estSjY5Ppnoz1oqOVgNF4XXiPFtH1DoUxaFAs9iFOOlX0x11H8RX
         LzkCDZ/B0lHgaOFt//L5U1tRUKt5r8ykQj7K2IxtR1jZnuURZPAn/0RkvmfArxQzWYKN
         H8KHkG1KUIVkhLd73ZmXcw8d5vyY4iRufeD0vJT+03CElmqoUAsboYRT6U96ugV6rsVW
         Wrsg3FqC5bMm5hJGOWF2oSWHBap1EIE21IcXqRb/I17KuXR3LD0gvMXvmBTruO+Higod
         YOR9G+OVNi6JKy+HSCmikfetDg6vsla5ceVBJhQjNXIYJUH5q2OEpcO3FOhSLBQaIX4T
         8iYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=W6owKkia;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e23sor129518otf.98.2019.06.06.15.06.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 15:06:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=W6owKkia;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EIr4OnOI1xF9wai5ier5nmSpwnMBcVJFFbPwhyrlfw8=;
        b=W6owKkiaiucLtIk2d/rhThge65YAuZhOXdGbJAq1YJnZeuj3agBqhdzoWw4pAHpEGG
         yCCRRgubBcq/P+3tO+QxBLrGvQWm34ZFjVhCGGnC25tsI1wz0ookadExgISatwc+xFwx
         9F3A1KcbDxhZpKNcMECopMoti2uf29JMv8oNXtACIP4ZdnAKSAeFcKK0Z75QstHVe1Kk
         FSNS/e4ugOpcEKATo1xHjQe71a839vKxrezJgS4nSTbtKrDnRK96iahNefKSCqeqIl7K
         GpNADCiQeyijYdm/jA366lM8s7uLcFJlrvqzsE5Q567T+TEojZQ525tKJu3IpPIztD1S
         rFqw==
X-Google-Smtp-Source: APXvYqycw+T+CReJfdLZE2qHIqv0pPOCCdRZcOCC2XXW8oc8RYjE0NVBkRV9yjOJGx4MnVYldEDTHY2D/nu9EblRWvQ=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr12110810otn.71.1559858798146;
 Thu, 06 Jun 2019 15:06:38 -0700 (PDT)
MIME-Version: 1.0
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977193862.2443951.10284714500308539570.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190606144643.4f3363db9499ebbf8f76e62e@linux-foundation.org>
In-Reply-To: <20190606144643.4f3363db9499ebbf8f76e62e@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 6 Jun 2019 15:06:26 -0700
Message-ID: <CAPcyv4hHs75hYs+Ye+NHHiU31C6CnBqCFdo=2c5seN7kvxKOrw@mail.gmail.com>
Subject: Re: [PATCH v9 11/12] libnvdimm/pfn: Fix fsdax-mode namespace
 info-block zero-fields
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>, 
	Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 2:46 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 05 Jun 2019 14:58:58 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > At namespace creation time there is the potential for the "expected to
> > be zero" fields of a 'pfn' info-block to be filled with indeterminate
> > data. While the kernel buffer is zeroed on allocation it is immediately
> > overwritten by nd_pfn_validate() filling it with the current contents of
> > the on-media info-block location. For fields like, 'flags' and the
> > 'padding' it potentially means that future implementations can not rely
> > on those fields being zero.
> >
> > In preparation to stop using the 'start_pad' and 'end_trunc' fields for
> > section alignment, arrange for fields that are not explicitly
> > initialized to be guaranteed zero. Bump the minor version to indicate it
> > is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
> > corruption is expected to benign since all other critical fields are
> > explicitly initialized.
> >
> > Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
> > Cc: <stable@vger.kernel.org>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> The cc:stable in [11/12] seems odd.  Is this independent of the other
> patches?  If so, shouldn't it be a standalone thing which can be
> prioritized?
>

The cc: stable is about spreading this new policy to as many kernels
as possible not fixing an issue in those kernels. It's not until patch
12 "libnvdimm/pfn: Stop padding pmem namespaces to section alignment"
as all previous kernel do initialize all fields.

I'd be ok to drop that cc: stable, my concern is distros that somehow
pickup and backport patch 12 and miss patch 11.

