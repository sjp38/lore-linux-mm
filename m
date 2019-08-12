Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B8ADC32750
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:39:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 487532070C
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:39:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="W5RPcjMy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 487532070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC1B86B0003; Mon, 12 Aug 2019 18:39:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4A886B0005; Mon, 12 Aug 2019 18:39:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C386D6B0006; Mon, 12 Aug 2019 18:39:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0253.hostedemail.com [216.40.44.253])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC046B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:39:24 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3F3F3180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:39:24 +0000 (UTC)
X-FDA: 75815243448.24.silk89_51f922147325c
X-HE-Tag: silk89_51f922147325c
X-Filterd-Recvd-Size: 4327
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:39:23 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id q20so12308031otl.0
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:39:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3aW5whQDJuBeImZ/vm/gZQhI4k4oQ8vroJ1EZoWTTJg=;
        b=W5RPcjMy2nSOxlc4JEQN/FwtmfGeYjojp9ZODu4ApD4CFAxXskqe+/tMV9edw9LUdx
         qnlUND2MQlVVlnOu7OGYLgJuZf4cj69zqu/4J89ENTbTDUFhgZrGN1dcouiEGSJDIKTv
         o/JtrRgZ/xJIsXmeC3F8OwvGykjcnMREp0KRFnpgOCL6zagxsRbC5C54aynLQTRDUqYi
         jhXMUGbVLruMjszhZFEpIvilTWNyNkBnr6HlHaN1RHkovoMhGAGAv6/rEmt5BZq726Yv
         kL8Nyzc4obRWZMKrP5ghFcL3rhUa8D/iVtsx1IjYskP+I4BJK7OlaRrKsNReR5wsC6RW
         hwaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=3aW5whQDJuBeImZ/vm/gZQhI4k4oQ8vroJ1EZoWTTJg=;
        b=PXLUPJjPq6YQk0971u6zitsXEklYqSNfAX7Dj5GtVVrmP06U9X053bUq2j7/S6VS/e
         0Ov4FVfgxB94hCcT9FMyjXDnYIPHcvTgZOvQexfpz846SzQph/0U08cuqgCD0Und+aKi
         cCqJQeeKngaXpKRMPrQ0snv3oLMWy45XGW5Uohb2AgfmdrueFM4G2sY1go/7MCw6mwMs
         mzSzksLLbU89ECxNY8f0YnpYg4WiWB7M+mPaXWIP2J5grZgDiKgDVe7OXdjNzSEzsWli
         jwFTxRMX5bmVBHTJHvKdMud63+hk1kyOlHSghOjgM61RdH5dCRJjx32vog/M6D16vK29
         T5xQ==
X-Gm-Message-State: APjAAAVNQvLwfz3Z6TNLEDVGJRMZ9eboq5NQEtVLML24/BGwY94a9FXV
	NSmrdu4OYy6XgHQ2I0JmE24yDhYbudRNWxluD2a7Kw==
X-Google-Smtp-Source: APXvYqyZa9vrGETWKw/3K2ZNQJVHXbpz2NU1cLAvQDyLfoeTJYzgNcrQQuvBKjD9GBMcejKS62NxlzuqZX/kdrrVoDI=
X-Received: by 2002:a9d:7248:: with SMTP id a8mr33233142otk.363.1565649562325;
 Mon, 12 Aug 2019 15:39:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190812213158.22097.30576.stgit@localhost.localdomain> <20190812213337.22097.66780.stgit@localhost.localdomain>
In-Reply-To: <20190812213337.22097.66780.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Aug 2019 15:39:11 -0700
Message-ID: <CAPcyv4id6nUNHJxspAWjaLFSPyLM_2jSKAa5PDibqeQXP0yN5w@mail.gmail.com>
Subject: Re: [PATCH v5 3/6] mm: Use zone and order instead of free area in
 free_list manipulators
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, KVM list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, yang.zhang.wz@gmail.com, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 2:33 PM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> In order to enable the use of the zone from the list manipulator functions
> I will need access to the zone pointer. As it turns out most of the
> accessors were always just being directly passed &zone->free_area[order]
> anyway so it would make sense to just fold that into the function itself
> and pass the zone and order as arguments instead of the free area.
>
> In order to be able to reference the zone we need to move the declaration
> of the functions down so that we have the zone defined before we define the
> list manipulation functions.

Independent of the code movement for the zone declaration this looks
like a nice cleanup of the calling convention.

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

