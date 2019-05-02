Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C5E7C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 19:18:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43CD92081C
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 19:18:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="oY66xYN+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43CD92081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFBDE6B0003; Thu,  2 May 2019 15:18:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C85136B0005; Thu,  2 May 2019 15:18:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9B046B0007; Thu,  2 May 2019 15:18:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 700516B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 15:18:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e21so1523225edr.18
        for <linux-mm@kvack.org>; Thu, 02 May 2019 12:18:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/EtrDUZnPlRu7IrcyamY8IpVJksLUEb2L4C6Vl0TUQE=;
        b=lQN4x1JJOzB+uJzOs5cdtRCjJARxgiAJpVl3T+5K7L/4Zj7OLZNpw8XNQGA139uVCS
         TiBugQRg48QbmL7BW+InZT7khnKDyJhsTRO8nqysvW+6eoS3yck9B53DjdDRyHGphHFH
         6CmImYtapgeTKuvfNdcaB6/9LlpQSLs3YugYgKjts96dhdX/BqbxUGMdFaNYZVuRlex/
         cEE0ENHO+gpeR5D/9kn8j0x6oyxoFAjyh+4LptDow4oR9NuTWKpJpE3ai2i1Dn6/cQgs
         0WIz795zqK8ZQ2TyAMqICinVBLpiIGWlOaO7tFF6v9xTvjKbOM9SLvgMHxtGP50d1ajI
         NfeA==
X-Gm-Message-State: APjAAAUf9Rv+lB174wj/R8G0yhZVMRH9CdcKjY2URsc+yj92PmYEuY5d
	rx7YTmzILM0IzqV29mOUGt+FqXy+/TgYwPNXp81TnPbMwRtL96gUi0P9ldob4PFi3REkXN7Bwnj
	UEzsiiqTekJ/bIH9WiTNfOMs6PaDHKNINDfGtcsj0F3/IGZ4O/QZKnZYiAEYAZq9SyA==
X-Received: by 2002:a50:b4bb:: with SMTP id w56mr3834833edd.40.1556824728942;
        Thu, 02 May 2019 12:18:48 -0700 (PDT)
X-Received: by 2002:a50:b4bb:: with SMTP id w56mr3834771edd.40.1556824727851;
        Thu, 02 May 2019 12:18:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556824727; cv=none;
        d=google.com; s=arc-20160816;
        b=LZqbt2OfT0C4aWvSsgI7MHmNH1QE4CcTTnkJfTgYPKSNiQWdXgSCWTOOGESznkozWy
         dMJhow5n3AdzarsAS2211jZRvpeaGjU9etBrjj0EOYbI4KRs3ZX9wyIewUAg0vm0f5nW
         FDitrRT1Gi7oMCOyfySGk2tC74fOq1yuzVyoGwbSfqrHX6MDACpSnwS4p3qO2ujoe2XN
         sLCmQYV3byWQhesDYHPHg7goFIPv4iH1WRSOVTaWvmnTX1wpDIKW659PDjnPu6N2A6UE
         vwoRCrzXDJ5eY2ke/WNfeTCf+dGFNXAkN+Gzi4u8lDxrM/g7YHXYDzEUXvhcN6yY7h1n
         +D4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/EtrDUZnPlRu7IrcyamY8IpVJksLUEb2L4C6Vl0TUQE=;
        b=FKSph2pFFUW7AnQI2gIhMhQmzg11HdP6Xc2jVOK5PjGoFGD2Lckq8IO2APERDhRubz
         AnK0ZrjPNTTuc1t1FtebWWuFCVYzM/9O8NVEyhBtLTjMv7arsxngkY+WsXfpwlU6o0Nt
         3werqlHv7CRRq81dy+SendI5QyPN1FImQqb/BzMmfKnzNf0oG54L0mgxsC8U/Y7p3g2w
         IvgfIp5MZeInEccqnSitFKB6txWfKX7VRGssring/gFn/djRUsceAHbfHBj88DyrDrkS
         DagXJLde96zqqS6YMQq5ZszgPPgfsCxbrnc0LC47SA1w0jibE3jAKKntxFJ41wUC4lqf
         u1Jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=oY66xYN+;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6sor1192020edh.27.2019.05.02.12.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 12:18:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=oY66xYN+;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/EtrDUZnPlRu7IrcyamY8IpVJksLUEb2L4C6Vl0TUQE=;
        b=oY66xYN+gJbH6VpzA77vhKfQaiig9FE2gWSvaganWGQHxbnAWNBjdK5IxmHDl/lulB
         6W2/Xu6OkEtP8EzI5IoyuCT9YBGVw5tvyjPDFWBkUqfZQpnYmkvUeHHSR6HD9M3whi9I
         0RcBrH0LDorwvHBC018lfCEvaAiT8BwChZuwyw0bGNQ8t6reNn9yI72NAJTHpjLRUJlg
         LCM39zL0LwzvspTxYRli24Jer9qJRz+CVCjC6684O6EDMB0WaaYj3PyULoK2HTbRkXDi
         ghyRy0ZVgVkbC6WyahwWy/PSLoe00mm05d6lyrce//A9Vuv45sVK7mWoQ+xalrdJVd8R
         AILw==
X-Google-Smtp-Source: APXvYqzLcGp30q9Ib2/zU1la10GlqsQhJRi/epzUUZiwaqPYnOeJoISItPcXmhWHqTVl0n32Bm0pjTtLjkVqAOIx8xo=
X-Received: by 2002:a50:fb19:: with SMTP id d25mr3732372edq.61.1556824727400;
 Thu, 02 May 2019 12:18:47 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 15:18:36 -0400
Message-ID: <CA+CK2bD2b5XZCxGXQ47XXRA2RFvc69u2LKx7pu4Mtvw_ezMDLg@mail.gmail.com>
Subject: Re: [PATCH v6 04/12] mm/hotplug: Prepare shrink_{zone, pgdat}_span
 for sub-section removal
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 2:53 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Sub-section hotplug support reduces the unit of operation of hotplug
> from section-sized-units (PAGES_PER_SECTION) to sub-section-sized units
> (PAGES_PER_SUBSECTION). Teach shrink_{zone,pgdat}_span() to consider
> PAGES_PER_SUBSECTION boundaries as the points where pfn_valid(), not
> valid_section(), can toggle.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mmzone.h |    2 ++
>  mm/memory_hotplug.c    |   16 ++++++++--------
>  2 files changed, 10 insertions(+), 8 deletions(-)

given removing all unused "*ms"

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

