Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D32CC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:12:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3164C208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:12:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="DDH2tF8r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3164C208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D17C76B000D; Mon, 13 May 2019 17:12:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA0826B000E; Mon, 13 May 2019 17:12:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B68316B0010; Mon, 13 May 2019 17:12:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8994E6B000D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 17:12:07 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id s64so5290497oia.15
        for <linux-mm@kvack.org>; Mon, 13 May 2019 14:12:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ehW85Lrv2Q48sCjGFVYU8EiJvcqJ/cEoN0rsLhKwFn4=;
        b=kC+pHHd8bfcY5r4mdC2SIcn6QLDSbLg11IFmskg+BvEchQEUx6d29zoOS8BmQ0+AGf
         5TuTRg/8+KNn5tXL1uTCivHtXhSsB8MW/bKuCxHuTP4q4V5vYNzj5dXkwojupLj/ns5P
         miTvvB1tyAnKDM+yhylOO6Lvy5oMuNuowgvL+03zwwja2+lrkyq59B8Wa4+WjJXSfGRQ
         dl9XTPi8BLLcEKpcAGPhl4N+3uiNDWRvYuZmuMtP1UPjddViVw36dR95s+zn3tGr6so9
         UMW7azE1GJdxi/Wb+3t6qvXOCznJiUytuEYmh4+edYX/TbWX9djq8VpRjSmioKpdNutr
         ySlA==
X-Gm-Message-State: APjAAAWjgqSen/xRUtpqC9Zz1ASHEXIzmj/45GmnRLqa2PBlWUuRSTi9
	xBI2ymarlp8ihYgKk+0Xk6cgr0JH7KFfXMqFJntTV4YdvqIU+aePgyVEt9akwz04vCffMuR58UG
	S3Xb67MlFQu6mKCSK49podOCoE/Ph3P5z3T1adPYcZPnEimTNKGPse0UwBGDpmvRSHQ==
X-Received: by 2002:a9d:6519:: with SMTP id i25mr18093867otl.287.1557781927189;
        Mon, 13 May 2019 14:12:07 -0700 (PDT)
X-Received: by 2002:a9d:6519:: with SMTP id i25mr18093832otl.287.1557781926628;
        Mon, 13 May 2019 14:12:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557781926; cv=none;
        d=google.com; s=arc-20160816;
        b=HSIegSNnP3ENGdUdJy5Nl0uDCobUOqMdeoUTYsm69CxgY05NrqkD/BCGb1nvO5duu+
         S/67Z+s46fjnODMoQBW6BFYVBkC6o1hgq7nVlb0u0HeS05pmNRbHqYW9i1wg1PjY8j/C
         QXJY8DfzfHxojXXkK3GVcbqgLGfx7QmHJpsDhnok1+FZW3sDqpuw6ntuyGNwnru+QU+y
         Atpzm3BsWg4xmVcmDf/5ICZXeiY23+MKzp2pGcObgsUbFoO+WJF6x4569f2d7trmv+US
         aC/e0NeQ9x235BYgsUzZtsY0zckhOdjVJ1PunpAG2VjGcn7GzRW43MJccLg2CuD/7rvb
         qZqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ehW85Lrv2Q48sCjGFVYU8EiJvcqJ/cEoN0rsLhKwFn4=;
        b=rwRLIbeqWEzxvr62sxVjmHdjpreezRp3wbRYgqxXBPhXc4lgO3Wh7umZlHZEGJmoWL
         ciArh97POhZJKTD92K/4WrXrb1rM0bnb9xhjTh81KQy+i71OL90rZ0PLCjCYvr4AmRng
         jpHIvQG2bEDO1U12vqKz4/KcvreAas/u9TvoaKU+IKX1FYs7VxtUBNsHzpegBCsWZQC8
         4bGbYy/R5W/j9OZZUhpDVwSw6ZiYqT0BS+W76nakmlAqbstkL9Na2LlNt3R/AERuja8o
         F2r/lSLLGYsy6d4McHNiUTO4EfOZua4hzl+76pJ/ceLwkTbxzAjSi2p0Wvhk3uB+rV80
         naeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=DDH2tF8r;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22sor6518717otq.137.2019.05.13.14.12.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 14:12:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=DDH2tF8r;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ehW85Lrv2Q48sCjGFVYU8EiJvcqJ/cEoN0rsLhKwFn4=;
        b=DDH2tF8rRfIjsd+6p3tNZ6N0FrylBCHLkuudu7uIV1T1yuGKEfmS5nhaufD2LxCH0n
         G845ptMmk8uLtcFNrOm9RJ/y5yUNcE06KAhjuzSEvjcwqluLZzThkkFoVLMzDS/GRFiQ
         E3YJqmPgTJDanm2yChPEe9Htk6yEnKKy74gZ1xdIUD/wHzbHnBDGzYiaAisiKcyMiL43
         a7ia7WeecOqq9//fSUFEgti9KcdEQBl+Yf08zwAb8MthphEbW8tsStK9BfeWjBslJy9P
         /aU3hHSwS4cAoxn925mw+G8S7Zm+GNjhEPotnhkBeJGxfQcKkGFVGwhIkvS82qmcTcOv
         6R5Q==
X-Google-Smtp-Source: APXvYqwIGJ0PBLErnWxuRYnfK8Gzj1P5cw9UmR9BtnvGHQjAVMKGB06nxi/SpfU6EmNEkLZmuWLghYQYRcySk2jRhMk=
X-Received: by 2002:a9d:6f19:: with SMTP id n25mr12997789otq.367.1557781926319;
 Mon, 13 May 2019 14:12:06 -0700 (PDT)
MIME-Version: 1.0
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190513210148.GA21574@rapoport-lnx>
In-Reply-To: <20190513210148.GA21574@rapoport-lnx>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 13 May 2019 14:11:54 -0700
Message-ID: <CAPcyv4he64-d=govm4+OEt75gxeuLZcrwrhow5dT=rA3KwQ4JA@mail.gmail.com>
Subject: Re: [PATCH v8 00/12] mm: Sub-section memory hotplug support
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, 
	Jane Chu <jane.chu@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Robin Murphy <robin.murphy@arm.com>, 
	Anshuman Khandual <anshuman.khandual@arm.com>, Logan Gunthorpe <logang@deltatee.com>, 
	Paul Mackerras <paulus@samba.org>, Toshi Kani <toshi.kani@hpe.com>, 
	Oscar Salvador <osalvador@suse.de>, Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 2:02 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Hi Dan,
>
> On Mon, May 06, 2019 at 04:39:26PM -0700, Dan Williams wrote:
> > Changes since v7 [1]:
>
> Sorry for jumping late

No worries, it needs to be rebased on David's "mm/memory_hotplug:
Factor out memory block device handling" series which puts it firmly
in v5.3 territory.

> but presuming there will be v9, it'd be great if it
> would also include include updates to
> Documentation/admin-guide/mm/memory-hotplug.rst and

If I've done my job right this series should be irrelevant to
Documentation/admin-guide/mm/memory-hotplug.rst. The subsection
capability is strictly limited to arch_add_memory() users that never
online the memory, i.e. only ZONE_DEVICE / devm_memremap_pages()
users. So this isn't "memory-hotplug" as much as it is "support for
subsection vmemmap management".

> Documentation/vm/memory-model.rst

This looks more fitting and should probably include a paragraph on the
general ZONE_DEVICE / devm_memremap_pages() use case.

