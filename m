Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6F0CC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:59:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 493C822BED
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:59:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oqCfu2vZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 493C822BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A729E6B026A; Thu, 25 Jul 2019 11:59:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A23318E0003; Thu, 25 Jul 2019 11:59:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 938938E0002; Thu, 25 Jul 2019 11:59:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 76BA06B026A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:59:30 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id r27so55358522iob.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:59:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qK60BCTTRu0Ys+kw65S0SEpX7dQ3Yakjf+W+ppKoJMM=;
        b=HG9vjfNjvSTL2Gs328pdJhR27g6lhlUuYzdVpXbTPafg27BQrB0xLCBA2EvIk0vG03
         2FSUm3sb8InCVZG+7ozFVbRfVIrs7+wd9agNnFWIq2EL9pXxuKalcsRVfdv6uO7ENCqP
         Zt42JTaAgpkqEMDW5kueignS4tOZqzP/LUzKDxN/69niqa/wMNHYx8LH8M7qt/eZDIv3
         lO2DDc1A3q7uizN4W/k9n/06MjhxMhVVAPxTa8ewGhNw+w2tkB1Y4wbWbRQ94rheow1U
         y2coYkmMRg127Poy2Pqy4ozt8hth7qj53U44kxvXjFlL9YzLPpHIx04uPjxDZKmG+x/f
         we/w==
X-Gm-Message-State: APjAAAUZ5GUMe/O2dNKWySOR2k4oRakT6H4N5mYTS7jPvB6kJZO8M17M
	n0uKFeSyw2hsfAsaRO4Mv+HdgXzMkHpxknwNu9s0ZvDC+o5B4XUDOIVaXyTXdzTh0oAujt8WC4e
	zGMYt53bFVGBy9henxxNew/y1Nb3euuy+9oH4C7AUmelje5VeUcwErk2CHLiwPqQsjA==
X-Received: by 2002:a5e:c803:: with SMTP id y3mr45039084iol.308.1564070370230;
        Thu, 25 Jul 2019 08:59:30 -0700 (PDT)
X-Received: by 2002:a5e:c803:: with SMTP id y3mr45039036iol.308.1564070369541;
        Thu, 25 Jul 2019 08:59:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564070369; cv=none;
        d=google.com; s=arc-20160816;
        b=lB6eC0O1d0nZVrfi79/T/h8no60j2Sos2hxWjro+4wDkTDes27PKf0C6O2usXBooDf
         Bhhy7nkJd2I+p6V3cXyUPmlpX/Wu2WX1EmIj8ZQple8UAfe8EM0aZrDh15AYI6RkYKkP
         XTeWSrDjbo997aj5f9V61vLa18PFhAeBY1XAfORPAZR8Bwyhkgx9163oOYadD4CqEXnK
         9KsJp9gItOhe297JvxB7uoXrsw4/+L2/0rJiSvzYsPATZwfBhM7MfOKWIk2FIpWWKRq9
         2U8/xJvRugMroIuZs3DC4x+J2rldPFisLX02pB6inloB3fdVhW289DE2B8uoEPzSh8c5
         rQ8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qK60BCTTRu0Ys+kw65S0SEpX7dQ3Yakjf+W+ppKoJMM=;
        b=kYL4ew9iYA7N8J52Im9yCcbG8dmFgsFtLBLkYA/0vFWIU0jIas6jzPOujJf/zP6d6H
         ftKtqW9UMB66Hj9YG6dD+bWbwd0I1lx0sC/WKttnld5A5BpDSdQSUz7JmUTCSYOjk3im
         4rMpsiuQGyOii2MZrgio438GAjpvg4Tmo7KnrOJAkgOGY1ifAqXUjgtWQzSJSZY59mBz
         dGsmGZOu/b0k2zicHG4lEU2NmH48geKPkp6gVIAaAAYHMKmI1eyS9tzR0FNT5EsVwr7W
         lZpbJBnw/GyMLffyMLhbctq//fjWeHh2vpmp3RcyiwtcW8jer8g0tvQttDlCA8EqC+BJ
         dC5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oqCfu2vZ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n200sor35309746iod.116.2019.07.25.08.59.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 08:59:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oqCfu2vZ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qK60BCTTRu0Ys+kw65S0SEpX7dQ3Yakjf+W+ppKoJMM=;
        b=oqCfu2vZEmKMr8jRkoBDSP/46uQ6yqxt8toi+TVwd67qyXZK0EBxRVYSpECs1dwMez
         IcJIExjgCycm93oaDl70T2DnEn7kMwO14tnS8UtAuIfAxD0Ln5ChwW4wMj7sr+cqrW43
         yqY55w0i6b+GOWyP7gKwmC458qQHUeDS97+wQoA3lDOdm/pWF1L93CK72iojAHynec/9
         USk3f/L5BqSWz3PuRVIgj6ptLf1A1c1Acf4Il4Li+zceMw4N8A0Ba+Y37CdXImGl4IQJ
         ZI5OmwkoV2oZAFYErftwgUqwAR1e1gcfGZxglhUJGt6g/ZSQJdEo/2T29phDR2gqyXky
         nXCA==
X-Google-Smtp-Source: APXvYqykv1YdLQoWPp1mD51S3A7Q+qMzrIevwBDJOREyxPzWS4W+wUHAKx/78O4j5/nzoqGCrsWrL3POrUlIcbXB5S4=
X-Received: by 2002:a5e:8c11:: with SMTP id n17mr15281210ioj.64.1564070368966;
 Thu, 25 Jul 2019 08:59:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724170259.6685.18028.stgit@localhost.localdomain> <a9f52894-52df-cd0c-86ac-eea9fbe96e34@redhat.com>
In-Reply-To: <a9f52894-52df-cd0c-86ac-eea9fbe96e34@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 25 Jul 2019 08:59:17 -0700
Message-ID: <CAKgT0Ud-UNk0Mbef92hDLpWb2ppVHsmd24R9gEm2N8dujb4iLw@mail.gmail.com>
Subject: Re: [PATCH v2 4/5] mm: Introduce Hinted pages
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Matthew Wilcox <willy@infradead.org>, Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 1:53 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 24.07.19 19:03, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

<snip>

> >  /*
> > + * PageHinted() is an alias for Offline, however it is not meant to be an
> > + * exclusive value. It should be combined with PageBuddy() when seen as it
> > + * is meant to indicate that the page has been scrubbed while waiting in
> > + * the buddy system.
> > + */
> > +PAGE_TYPE_OPS(Hinted, offline)
>
>
> CCing Matthew
>
> I am still not sure if I like the idea of having two page types at a time.
>
> 1. Once we run out of page type bits (which can happen easily looking at
> it getting more and more user - e.g., maybe for vmmap pages soon), we
> might want to convert again back to a value-based, not bit-based type
> detection. This will certainly make this switch harder.

Shouldn't we wait to cross that bridge until we get there? It wouldn't
take much to look at either defining the buddy as 2 types for such a
case, or if needed we could then look at the option of moving over to
another bit.

> 2. It will complicate the kexec/kdump handling. I assume it can be fixed
> some way - e.g., making the elf interface aware of the exact notion of
> page type bits compared to mapcount values we have right now (e.g.,
> PAGE_BUDDY_MAPCOUNT_VALUE). Not addressed in this series yet.

It does, but not by much. We were already exposing both the buddy and
offline values. The cahnge could probably be in the executable that
are accessing the interface to allow the combination of buddy and
offline. That is one of the advantages of using the "offline" value to
also mean hinted since then "hinted" is just a combination of the two
known values.

> Can't we reuse one of the traditional page flags for that, not used
> along with buddy pages? E.g., PG_dirty: Pages that were not hinted yet
> are dirty.

Reusing something like the dirty bit would just be confusing in my
opinion. In addition it looks like Xen has also re-purposed PG_dirty
already for another purpose.

If anything I could probably look at seeing if the PG_private flags
are available when a page is in the buddy allocator which I suspect
they probably are since the only users I currently see appear to be
SLOB and compound pages. Either that or maybe something like PG_head
might make sense since once we start allocating them we are popping
the head off of the boundary list.

