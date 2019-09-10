Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35482C49ED8
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:48:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAA4421670
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:48:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PzcNTtgF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAA4421670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8733C6B000A; Tue, 10 Sep 2019 10:48:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84A986B000C; Tue, 10 Sep 2019 10:48:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 788766B000D; Tue, 10 Sep 2019 10:48:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0139.hostedemail.com [216.40.44.139])
	by kanga.kvack.org (Postfix) with ESMTP id 59D816B000A
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:48:54 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EAE58180AD7C3
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:48:53 +0000 (UTC)
X-FDA: 75919292946.14.food26_87d7092480f5d
X-HE-Tag: food26_87d7092480f5d
X-Filterd-Recvd-Size: 5517
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:48:53 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id h144so38059497iof.7
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:48:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=y51Wmq0LRgJPRQu0wESyACMKgIN3oGN4hPyCwS8B9Fw=;
        b=PzcNTtgFRZmzMv0K1KK0mg45o4Yljkgb90mn498QkmecMBhhZ5hVU/NDRq0XyRodXv
         oqt8Gfa8DdtOS8BNXSn78trtFzo/cG4x2Q3hTi0E8/87ACzQRuE0GaG6NPFNj2w7i5hz
         d9eH/XfpdFJ4ZsSIItHV5fPjLK39IDFhjDsIgyoeiWYb/OgukBbYhH7k63i7aX9m43JY
         B2q7D5PGC8y5aL/e8xurQByjUcIrfbOUk1u3uk1YXpi2aKIq2f9GOVhCzAD0nNiZ6KBc
         mxNmVjxT2XEjrQHY1egt7O+EREMCd1qYYvBFoCb6XuBlHZGCELCMyobbvgTykr1X77AJ
         JGUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=y51Wmq0LRgJPRQu0wESyACMKgIN3oGN4hPyCwS8B9Fw=;
        b=iWF2tnpWqFJaGlUPIrHSAFx+I+49TN3XHui+1p6lbNTj9Vj+aPM9Lex3hyn2GzmTi6
         EFFOZtQE8XJYJgVj3xDylZjBlKBwPUu5oEAAzEe0F6fl1rgKF+QPlZYouaNVYJnhwy1k
         EHUOKx7323kf7Qe0CA0WWqSAVVI70VWUYE/jOhZq8uZw0Bu880AwXcamgJNPR8krweQa
         LzYg0AF17BdS9NJgBYNlu5+0DIQGTrC0H7UowOBLfmaeIhm02yjsVq9opJAnvSmAbX46
         KTJEfTiYsCFRrWt48yvUXfIxx3tyNofoBgheOyO4Bfn4eItgFJmR/m71wK4mquWWrCwF
         LzVw==
X-Gm-Message-State: APjAAAUfClo6q9OfvxlsYpIV6kxdvmXFaIUWGxVzRsUg37N3rQobH0jN
	K2dOURP0DGwCCXnKaQmCpUisWV+YrEcY0TN/X4o=
X-Google-Smtp-Source: APXvYqwN74shiAyKliNs3JxV0dTTuWrOoxH7hX54E/H8prvfohDIALH6Vobq+JG8UlF+hibP/Y2WKvw7cp3R4NGGfXs=
X-Received: by 2002:a5d:8908:: with SMTP id b8mr1353105ion.237.1568126932604;
 Tue, 10 Sep 2019 07:48:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172520.10910.83100.stgit@localhost.localdomain> <20190910122030.GV2063@dhcp22.suse.cz>
In-Reply-To: <20190910122030.GV2063@dhcp22.suse.cz>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 10 Sep 2019 07:48:41 -0700
Message-ID: <CAKgT0Ufw1h45q9H5jraOJkRwvnrxfVNe99bVF1VWCLrzxCrMmg@mail.gmail.com>
Subject: Re: [PATCH v9 2/8] mm: Adjust shuffle code to allow for future coalescing
To: Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, will@kernel.org, 
	linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Pankaj Gupta <pagupta@redhat.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitesh Narayan Lal <nitesh@redhat.com>, 
	Rik van Riel <riel@surriel.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 5:20 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sat 07-09-19 10:25:20, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >
> > Move the head/tail adding logic out of the shuffle code and into the
> > __free_one_page function since ultimately that is where it is really
> > needed anyway. By doing this we should be able to reduce the overhead
> > and can consolidate all of the list addition bits in one spot.
>
> This changelog doesn't really explain why we want this. You are
> reshuffling the code, allright, but why do we want to reshuffle? Is the
> result readability a better code reuse or something else? Where
> does the claimed reduced overhead coming from?
>
> From a quick look buddy_merge_likely looks nicer than the code splat
> we have. Good.
>
> But then
>
> > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> [...]
>
> > -     if (is_shuffle_order(order))
> > -             add_to_free_area_random(page, &zone->free_area[order],
> > -                             migratetype);
> > +     area = &zone->free_area[order];
> > +     if (is_shuffle_order(order) ? shuffle_pick_tail() :
> > +         buddy_merge_likely(pfn, buddy_pfn, page, order))
>
> Ouch this is just awful don't you think?

Yeah. I am going to go with Kirill's suggestion and probably do
something more along the lines of:
       bool to_tail;
        ...
        if (is_shuffle_order(order))
                to_tail = shuffle_pick_tail();
       else
                to_tail = buddy_merge_likely(pfn, buddy_pfn, page, order);

        if (to_tail)
                add_to_free_area_tail(page, area, migratetype);
        else
                add_to_free_area(page, area, migratetype);

