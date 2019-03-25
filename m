Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5547C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 19:30:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A0DC20854
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 19:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="1mdk+MBy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A0DC20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F7E66B0003; Mon, 25 Mar 2019 15:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C86B6B0006; Mon, 25 Mar 2019 15:30:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 017746B0007; Mon, 25 Mar 2019 15:30:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA76B6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:30:01 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id i4so7076894otf.3
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:30:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=hXTt04+uP3CF2N6BhBBgJjHnEUj/7PvEFKIa60d+Aqg=;
        b=QpnaDHz2FDa2PUdypQm8mwEdIHJ3xmysXoVU+j5uHv8gZdxfgmYVFaemwHEvminH45
         MRVKiAfLgQ9wYa0M7yKDXNq4yJrnurun6tcv3lmvJ1CHGiNaMAlOdnjFjuXWuDWjuD4Z
         PiiDt+R9/iA0ZsTHr+bxIiINT/RwISnph6LCrIyAGJtJ/X9Hn2kzPLIEvo+e4ey4SCwp
         qGdLd1INwcY4LPwCvENqWt+CcDENPaw1gd8nAyDXQOmhQHgIbO+wWCaMfC+cKkTncBa/
         M1ox9GphGTygYCPQrvGgaN2VG/kTeErgw+KB4aHzqABZ7+l0TEvG386T5e0BlZVEEGHN
         uVAA==
X-Gm-Message-State: APjAAAUUsivEQS03BD07PtcBeEjv0xU85lasn/8eq0C3J2bE+xTrEAnn
	qc7lyvN6ZIBpfa7PBqYlpgeov3UdC0jhj6W1zfNP1A8tgl8p/JIAW13BkDvo+Xb8ee+/ZHMu2Oc
	Pf9IHHVDPYUQTD+BgWwxBbJBo16ed21Xujup8qBX3dDBMbikAg/g6xQ5xSOnwLaZI0A==
X-Received: by 2002:aca:efc1:: with SMTP id n184mr11429229oih.121.1553542201244;
        Mon, 25 Mar 2019 12:30:01 -0700 (PDT)
X-Received: by 2002:aca:efc1:: with SMTP id n184mr11429165oih.121.1553542200240;
        Mon, 25 Mar 2019 12:30:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553542200; cv=none;
        d=google.com; s=arc-20160816;
        b=C7tHY0LC5VF69tA7oQzT2Cuvlml3JltT2ymg76BKWcajVb6u6J9cmJmmoUiAIT9SKQ
         fPtBd5hQc754okB/nP7qRV8uzUVMBeQ1EivD7I6/F18Igbi1aKFIsyXQUfT74uReV5yg
         fIRozaeglzWWqYJruJ5uxbQD41kNic0QC+mbGl5wXiE7qe792jK6Ab+3c6CA4UGtGDa7
         j2W+y4Kl7uZd/u8SlNLf+/5FnW+YY3vbywtIXWJlXLInG051iuzl1VAA+JdJK8t7QGtt
         664psr3bdxsSeAqk40RN7YN1662h64TKocVvdYaip1Vkp50qCqakLEjO3U4nj8DC3uqW
         Q1mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hXTt04+uP3CF2N6BhBBgJjHnEUj/7PvEFKIa60d+Aqg=;
        b=1G9/oY+k95s9NGmp/6N5iukva5FvRr4zRaxP/naP+ix9OFvD6TGyPtB0v3Wu6o3erJ
         iPwSSHiv3DlT7ebOXFkNgp/qlQhZvCuL3DLlgMeW/90VpoGR6OmGbDYFCIA+ZRqxuwel
         VM/aCrnC6jROylAaNAkO+6sp56cd4wsvylOnqUZfV8fkmasvVB12FAN7LKNrTnfqFf75
         ZQkwFNJ+jqJjAIGjxgiQPElIBEVSFiAM7+zgBpZw0JKkW4Z1A6YpH1+kIsjlvaLv4Uvl
         O/n5mAU0ZxZeEzOzIHdanqClqAhxQ/cwiO7IaoWvkhvchOukiZ4cyQzGni6UfHDgfpsf
         21PQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1mdk+MBy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q7sor1563078otk.79.2019.03.25.12.30.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 12:30:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1mdk+MBy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=hXTt04+uP3CF2N6BhBBgJjHnEUj/7PvEFKIa60d+Aqg=;
        b=1mdk+MBy7JP5R/Slb3flUfuhDER9hIZOWP46hDJe4hA2ypCGSWakbhLIz+M86ZE5bs
         aOlurSVep85tCgTR1UQb/q6fr5Iwc+Wn7GO2M7iZ9MHdokXYk4cjabJofPmsycdAw4/S
         N31aGtC9FFAbwvAMOaZtnxe8vfDu5ROV/RUu13S2iAV44eJRiFXYJCVAyheQw0FbA3kL
         6yPvH8c5oxG4U6Qkq5/jjQMOHYbjexhhDqFUxBFQc8p2NkV9GlPJt2vtA8j4UGaw3XJm
         U5RgW2tclPEMtg+IkqJve0Uo3wMTR+hazLxQYs20HbwPGSdMb6u4l3/grQ0RUnYvq04x
         jGSA==
X-Google-Smtp-Source: APXvYqzta2v2fqC1QO5NTeyuYEcNckY9JIm9c1OXKwXu+ldirLp79DrEZBPZu7PqPXrr+kF52rLsHn7QgzxoalBkCmE=
X-Received: by 2002:a9d:224a:: with SMTP id o68mr20030389ota.214.1553542199941;
 Mon, 25 Mar 2019 12:29:59 -0700 (PDT)
MIME-Version: 1.0
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr> <CAPcyv4it1w7SdDVBV24cRCVHtLb3s1pVB5+SDM02Uw4RbahKiA@mail.gmail.com>
 <3df2bf0e-0b1d-d299-3b8e-51c306cdc559@inria.fr>
In-Reply-To: <3df2bf0e-0b1d-d299-3b8e-51c306cdc559@inria.fr>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Mar 2019 12:29:48 -0700
Message-ID: <CAPcyv4gNrFOQJhKUV7crZqNfg8LQFZRVO04Z+Fo50kzswVQ=TA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 10:45 AM Brice Goglin <Brice.Goglin@inria.fr> wrote=
:
>
> Le 25/03/2019 =C3=A0 17:56, Dan Williams a =C3=A9crit :
> >
> > I'm generally against the concept that a "pmem" or "type" flag should
> > indicate anything about the expected performance of the address range.
> > The kernel should explicitly look to the HMAT for performance data and
> > not otherwise make type-based performance assumptions.
>
>
> Oh sorry, I didn't mean to have the kernel use such a flag to decide of
> placement, but rather to expose more information to userspace to clarify
> what all these nodes are about when userspace will decide where to
> allocate things.

I understand, but I'm concerned about the risk of userspace developing
vendor-specific, or generation-specific policies around a coarse type
identifier. I think the lack of type specificity is a feature rather
than a gap, because it requires userspace to consider deeper
information.

Perhaps "path" might be a suitable replacement identifier rather than
type. I.e. memory that originates from an ACPI.NFIT root device is
likely "pmem".

> I understand that current NVDIMM-F are not slower than DDR and HMAT
> would better describe this than a flag. But I have seen so many buggy or
> dummy SLIT tables in the past that I wonder if we can expect HMAT to be
> widely available (and correct).

That's always a fear that the platform BIOS will try to game OS
behavior. However, that was the reason that HMAT was defined to
indicate actual performance values rather than relative. It is
hopefully harder to game than the relative SLIT values, but I'l  grant
you it's now impossible.

> Is there a safe fallback in case of missing or buggy HMAT? For instance,
> is DDR supposed to be listed before NVDIMM (or HBM) in SRAT?

One fallback might be to make some of these sysfs attributes writable
so userspace can correct the situation, but I'm otherwise unclear of
what you mean by "safe". If a platform has hard dependencies on
correctly enumerating memory performance capabilities then there's not
much the kernel can do if the HMAT is botched. I would expect the
general case is that the performance capabilities are a soft
dependency. but things still work if the data is wrong.

