Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90EEEC282DC
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 00:09:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 266E6218AE
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 00:09:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pnr8Qcmz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 266E6218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92A3B6B0005; Fri,  5 Apr 2019 20:09:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D7D86B026E; Fri,  5 Apr 2019 20:09:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EDAA6B026F; Fri,  5 Apr 2019 20:09:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBCD6B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 20:09:58 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e126so6069165ioa.8
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 17:09:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=+uZuXK3Cg5BkLu3R2m2Qt0Oi23SaZRCYQzeotiWu9hc=;
        b=fZ8bCv+b0WGJjxqYlcRoF9qj23whnJl2OWpd4gb2Tx3z0z0k2wSqmpM0JVU31rOY1L
         6hjl58wFR59Fw7OgS2lunjPeI9brNb0AUWid+AxR6mLKGaT5vJi5sW+6+GsmqwcNfazh
         I/sJtmsSLzRKv14cTMqk5RyCnhoNy3gRRoBZyOMAEBmjq1x7UNWXr4Di3ljdQz7IBcWM
         H5qMV0lZY1foa7Jw2V4YK70d+6OQobKy/iQS+3rvlmIx/NCRzDlpx2WMcOxfkXJSzdwS
         fNmdst44v917/PBJsK8caRUfPSeUdGryePSaMhyFEqJKMnvqN0YF32/2rFSFdyPPIGoq
         FZhw==
X-Gm-Message-State: APjAAAXYSpXAh7bpILhW4kKZBoJb6MSiGP1/YJdR3ldepc7afSp+en9D
	f3vWzc9JZd6/gTUhqLNKHTY8uNe8dEiL2EdXV13y+WtIzXf4yXsgYksCwMIM9c/iz54Z0zkCYAN
	PbbE5bzvb0A5GnuvExDciBz5zKze7+sEucgYEQGA+96jgVOKCQwBauoiupXx4BmCpzw==
X-Received: by 2002:a6b:6b12:: with SMTP id g18mr9952855ioc.14.1554509397973;
        Fri, 05 Apr 2019 17:09:57 -0700 (PDT)
X-Received: by 2002:a6b:6b12:: with SMTP id g18mr9952810ioc.14.1554509396791;
        Fri, 05 Apr 2019 17:09:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554509396; cv=none;
        d=google.com; s=arc-20160816;
        b=LlR+6U+t6EASnMDwkQ3l5n7+qM7oY7zpus2g0P3JXrM0XZhb7KSm0zKuH6NnRCjIJ1
         u9G/6AsDj8mhsI1/LpCq3UEqxHwxvlwa92C8WhFPwOZ67D6NQ6w6yxl4eaSNBiJ50F62
         GZ/XlYlJ11d2am9YlvSZ9WfDXyi6Wu8XfP1FYNSMH5oyroxdanM9S8baxUyosLTzVHXA
         NrHuCz93T8c523KqH6dTrm44CZUMbAEgqCiNtv13c6vru9tmONjoBKbVHhRRszSOY26E
         fOuLOtWTtAGaXlRUDLIPQgFvk02A2w8d31Ezt3dDqhX18KF+pCgrGsq2raz3MMYXEOlZ
         VKqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=+uZuXK3Cg5BkLu3R2m2Qt0Oi23SaZRCYQzeotiWu9hc=;
        b=w07zTOyVeaNolPvCQlmNwEIgmhQfjlhWF6+TsVgEfEOBz9z5JN5dmrGdt613Iq9L3i
         h3eCyLa0rcFT5OPZO3NTPKp99w0Xe+OCvVdrTWXEme/tF+iQergD2LMz9yNl+S/zdXzU
         c7eGqf1XNnGV9vVfVydiPIzFDG4Zo//AsrWCTR5t+U4hHLhF1jF4Fbm8Q6Cpj2VJr+63
         /I+6ATHPusreJIBkXn13AnqmNQZuoJCAkyHzM8gjRI9r1vGfLuM6tHCv01F6s37+7Yce
         XUSUwQFPcDFtkGlSBCwN6hrqOyNrKMX+pPCKy6QZYPGc7BP8nukINOTWHMwrRkpTiokl
         8Tag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Pnr8Qcmz;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h199sor5995312ith.17.2019.04.05.17.09.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 17:09:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Pnr8Qcmz;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=+uZuXK3Cg5BkLu3R2m2Qt0Oi23SaZRCYQzeotiWu9hc=;
        b=Pnr8Qcmz5UA3Vq8hzId7rtXzoTDHe+wd5mhOyTxaUsKYIUhWd6C+4BBbLROLNVT11A
         88Rp2XHc7s0GEEh3AwJiGHc5Ytt1l+r5JTrcTdiRzGQ7ZJEd+ICBqAqPLOM7SALWyOaO
         xrl1kbNQINdnJ+49uLIfBIOvM/kB8G7IokkksV6x9SjHsdTvIhgXpVW11QQ4csezlTSZ
         ByFVwSr7wy6DiiH0RQEViqIFKCroQvgDra9/qD4bqUaI4wGgJHz6R9Jg5x4TpEbb8WP5
         MVBbAaM5ARHjDJp0KWy0+xahJHq9Eaf83OmNOz/ezj4d0HK2xSiFKFpG39UAvoYGPbaT
         jzQA==
X-Google-Smtp-Source: APXvYqw3Drw5oqr7TTrV7zTrQdEEoKBMGAwzJWRcUZ5Q6L3u0TvUlbUhcUSDaIhf45VwUMOvJ1Pg/hocSByuFV7OQd4=
X-Received: by 2002:a24:7c52:: with SMTP id a79mr12697448itd.51.1554509396242;
 Fri, 05 Apr 2019 17:09:56 -0700 (PDT)
MIME-Version: 1.0
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 5 Apr 2019 17:09:45 -0700
Message-ID: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
Subject: Thoughts on simple scanner approach for free page hinting
To: "Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>, 
	Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

So I am starting this thread as a spot to collect my thoughts on the
current guest free page hinting design as well as point out a few
possible things we could do to improve upon it.

1. The current design isn't likely going to scale well to multiple
VCPUs. The issue specifically is that the zone lock must be held to
pull pages off of the free list and to place them back there once they
have been hinted upon. As a result it would likely make sense to try
to limit ourselves to only having one thread performing the actual
hinting so that we can avoid running into issues with lock contention
between threads.

2. There are currently concerns about the hinting triggering false OOM
situations if too much memory is isolated while it is being hinted. My
thought on this is to simply avoid the issue by only hint on a limited
amount of memory at a time. Something like 64MB should be a workable
limit without introducing much in the way of regressions. However as a
result of this we can easily be overrun while waiting on the host to
process the hinting request. As such we will probably need a way to
walk the free list and free pages after they have been freed instead
of trying to do it as they are freed.

3. Even with the current buffering which is still on the larger side
it is possible to overrun the hinting limits if something causes the
host to stall and a large swath of memory is released. As such we are
still going to need some sort of scanning mechanism or will have to
live with not providing accurate hints.

4. In my opinion, the code overall is likely more complex then it
needs to be. We currently have 2 allocations that have to occur every
time we provide a hint all the way to the host, ideally we should not
need to allocate more memory to provide hints. We should be able to
hold the memory use for a memory hint device constant and simply map
the page address and size to the descriptors of the virtio-ring.

With that said I have a few ideas that may help to address the 4
issues called out above. The basic idea is simple. We use a high water
mark based on zone->free_area[order].nr_free to determine when to wake
up a thread to start hinting memory out of a given free area. From
there we allocate non-"Offline" pages from the free area and assign
them to the hinting queue up to 64MB at a time. Once the hinting is
completed we mark them "Offline" and add them to the tail of the
free_area. Doing this we should cycle the non-"Offline" pages slowly
out of the free_area. In addition the search cost should be minimal
since all of the "Offline" pages should be aggregated to the tail of
the free_area so all pages allocated off of the free_area will be the
non-"Offline" pages until we shift over to them all being "Offline".
This should be effective for MAX_ORDER - 1 and MAX_ORDER - 2 pages
since the only real consumer of add_to_free_area_tail is
__free_one_page which uses it to place a page with an order less than
MAX_ORDER - 2 on the tail of a free_area assuming that it should be
freeing the buddy of that page shortly. The only other issue with
adding to tail would be the memory shuffling which was recently added,
but I don't see that as being something that will be enabled in most
cases so we could probably just make the features mutually exclusive,
at least for now.

So if I am not mistaken this would essentially require a couple
changes to the mm infrastructure in order for this to work.

First we would need to split nr_free into two counters, something like
nr_freed and nr_bound. You could use nr_freed - nr_bound to get the
value currently used for nr_free. When we pulled the pages for hinting
we would reduce the nr_freed value and then add back to it when the
pages are returned. When pages are allocated they would increment the
nr_bound value. The idea behind this is that we can record nr_free
when we collect the pages and save it to some local value. This value
could then tell us how many new pages have been added that have not
been hinted upon.

In addition we will need some way to identify which pages have been
hinted on and which have not. The way I believe easiest to do this
would be to overload the PageType value so that we could essentially
have two values for "Buddy" pages. We would have our standard "Buddy"
pages, and "Buddy" pages that also have the "Offline" value set in the
PageType field. Tracking the Online vs Offline pages this way would
actually allow us to do this with almost no overhead as the mapcount
value is already being reset to clear the "Buddy" flag so adding a
"Offline" flag to this clearing should come at no additional cost.

Lastly we would need to create a specialized function for allocating
the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
"Offline" pages. I'm thinking the alloc function it would look
something like __rmqueue_smallest but without the "expand" and needing
to modify the !page check to also include a check to verify the page
is not "Offline". As far as the changes to __free_one_page it would be
a 2 line change to test for the PageType being offline, and if it is
to call add_to_free_area_tail instead of add_to_free_area.

Anyway this email ended up being pretty massive by the time I was
done. Feel free to reply to parts of it and we can break it out into
separate threads of discussion as necessary. I will start working on
coding some parts of this next week.

Thanks.

- Alex

