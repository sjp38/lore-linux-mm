Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A0FCC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:53:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE27720652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="E9hwztFA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE27720652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E65C6B0003; Thu,  2 May 2019 10:53:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 695546B0006; Thu,  2 May 2019 10:53:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55D9D6B0007; Thu,  2 May 2019 10:53:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0931A6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 10:53:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 18so1194608edw.6
        for <linux-mm@kvack.org>; Thu, 02 May 2019 07:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=dKGCEW6XzK5wy4m1GTL2dVQ217lYhqpqlUuT/Q5YrAk=;
        b=DS3RpIg5Ya446Yi4qIUqcK9cXJorHzY/7NuAxzkj/h8BAVer8+0r2BGbaY2QZ5o30a
         rNQtIutK+BN83L81KCG4Hirjsteuz5Silpm3af8v1tQqDAjHyKbU03k0y6iT8D0WWjvc
         BmCH0UNB6RfM0CRIjPcqv2C8V7nAPRJzo5o8g/fwkUm0rVfi76UW/WysEOxnfbqdHt5O
         HXmPratPaMZqwcMc328rsxUr6zvC1SisMjTfLtVXb8pgCQlGmXGU/exM9S8I02h+ls2H
         GnNEDcoUjdhjzzXG/FxmdQvdI1cWsbk+2nr2EXyMMZS6g2xYCiNpsNXlTOX+aF6gV+el
         jdfg==
X-Gm-Message-State: APjAAAU2ug1xDrqP7m98I0un0MpAKC/rLBFlS2+dOE8ZHjlwgUjKTCGn
	Y12L9tiIaN7pZWYf1YjekddrbKmb56UJNMGGF546gMxFd+FL1hRCTXsEr50XKMY/fBA/QyvYZzw
	eVo3t/tbgHf9iHs7U37jppdyQnufP6dTbsGKU8FbQ/SYt1ARNZVc0Ty1AtMLXC1J2wQ==
X-Received: by 2002:a50:9968:: with SMTP id l37mr2905803edb.143.1556808800506;
        Thu, 02 May 2019 07:53:20 -0700 (PDT)
X-Received: by 2002:a50:9968:: with SMTP id l37mr2905755edb.143.1556808799672;
        Thu, 02 May 2019 07:53:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556808799; cv=none;
        d=google.com; s=arc-20160816;
        b=AjHfRJq/L9hNJdGCdRQwjpvCrAcI7cn/MCR/4EhK3E+90cQZn8Whz0RRh70TLtyOe9
         h4e+m7w/q3DhTkS1h3oTzs2dK1MJBllvadauiAiCK4q7BA33XUz/2HY6yMrNdd4tS+A1
         zcRn773FVZ/umJbHtHqlKq2xnsfqFOLHSmEznTLw5mPdPDbHyupIF0I4xd7fGLn1ruFU
         nX0oA49CAEgeXwQk19VzUt/TKZJ1OFYrpkxgI94q7hK39nSQFE5+ka3XdyqeGfJrVwWv
         8lkXtpc1FBf2qey8Oo117T937B33f0wJL7PagGu6e7gD1OkMRrFg6ZoSMxDp8roKt7kc
         8mAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=dKGCEW6XzK5wy4m1GTL2dVQ217lYhqpqlUuT/Q5YrAk=;
        b=ZNVi2TiAXGyCL6SlPPDGSDGw9dlolgBmt9q2sbOh48ZlLvAD7J3NFCdwM3zWs7H2SG
         yTtxnCDwlyiJVEllFBXN4ptERYLv+UYemAR/FI/rdnQ4fgPQEK0oGubtunpXeFLYXpq9
         7O7E8cFTpmUZ5AAQBZl22X5ESU/jjfNzJonihVwhyB6raFihZJ7o9UuJuRg5eUVgEYkW
         YyKUZbzHMq/hCDv/bLZn0qlijv778piQ5hnFwJHbcmYROZfXIEWPGEaG+AmhXrwU3Tta
         aBVxs8zOol7xOkONCm8ztI/jdZ2a6RdL37e8YaKwcAEOYGG96UiAkXJPXZNHoL5RI9X0
         kGqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=E9hwztFA;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 57sor2544424edu.3.2019.05.02.07.53.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 07:53:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=E9hwztFA;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=dKGCEW6XzK5wy4m1GTL2dVQ217lYhqpqlUuT/Q5YrAk=;
        b=E9hwztFAlWAIt12OjHM7LZjhNQKHMm9PKOV4hYhj1sqs93tmAJcAHynyx9o1m/Q62l
         eFO0D2Nb0QO2aKaA6ewG2DLDNbxH6ydmK1i7PRFe8I1cJjnmFkwwDXnCoTEyn7ae78IJ
         PuIEHYIkx6WC6q2K5Yp411ug3cQtrEbF5nb9OzScSTLtlqUPy/RjdLub06YuwK0IkspB
         HN5wBjdS0eRi95e8Gd4DiAmo5jvXp4qbwOTz6Y+cESSb4O/49jHWtaKVKs95txPsgK4x
         qhClgbyewxA1wLSADBtMzY4mgzy1iwa9Q+OfBjDBgQGOKG83eaT9rV8Isd6AuZhV3iQ5
         Z/9A==
X-Google-Smtp-Source: APXvYqzG/pNwhK7Fv/OkZD+XGOAYkZEawBV2i/ZKUmVW/4byaSLkD4xJCAfKtzfrtZdWNgqALb1vdspOkKWJ8CrwwzA=
X-Received: by 2002:a50:b513:: with SMTP id y19mr2992384edd.100.1556808799112;
 Thu, 02 May 2019 07:53:19 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634586.2015392.2662168839054356692.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552634586.2015392.2662168839054356692.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 10:53:08 -0400
Message-ID: <CA+CK2bCkqLc82G2MW+rYrKTi4KafC+tLCASkaT8zRfVJCCe8HQ@mail.gmail.com>
Subject: Re: [PATCH v6 02/12] mm/sparsemem: Introduce common definitions for
 the size and mask of a section
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 2:52 PM Dan Williams <dan.j.williams@intel.com> wro=
te:
>
> Up-level the local section size and mask from kernel/memremap.c to
> global definitions.  These will be used by the new sub-section hotplug
> support.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Should be dropped from this series as it has been replaced by a very
similar patch in the mainline:

7c697d7fb5cb14ef60e2b687333ba3efb74f73da
 mm/memremap: Rename and consolidate SECTION_SIZE

