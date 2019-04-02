Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E992C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:45:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B2262082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:45:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YUSx16IW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B2262082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D09496B0270; Tue,  2 Apr 2019 13:45:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB6DA6B0272; Tue,  2 Apr 2019 13:45:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA5B46B0273; Tue,  2 Apr 2019 13:45:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC1C6B0270
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 13:45:56 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id p23so3510367itc.7
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 10:45:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=v5t/Y4J0o1SK+hPA+fwYsPBbjhkFvdldj8PMZh7RPww=;
        b=RfpXFvzcQNhDoG2hAffYUB+BcSddcCHZ45qMnQk7ixu5tX8vrbdMFzCpAXQdEuJThl
         mdq5p2eEqA8QFAXYkQesNRBifocDKEYW4IE1juja+Sdqfuwvb6+mBMkUYBdSY+FW22c6
         EEcHI7757AYhHEJIhEr+2p50uXJZtdi9czGbQ6QxFi2Gx7CIvYsS5a1+bt3K0DXg5qtv
         5Y31q9tq4flTTjtXUbTwndmK/+dMltGNpSVNhrTBWTN3qeLn6OCIEGrsZ35qmRc5YzCF
         KvkfU75jezfkWEfYi6vcn0C5OFk2Ee8Wfm3WnUmRKnMdn8alC3J80+NZ2sL5bP0Yu3el
         utqA==
X-Gm-Message-State: APjAAAUV2ZaNEgOD9zY9JJJnDOqy++WAsR8eY9muT2+VOEfRcD2xvoGd
	AN8K5H2B20CgaKh7fZTzapl8RZuqGmFZQcYLO8mnuKw725c5o4F1AMRNwqcOFe2gRiv1eOTMN+P
	7gy78zSMnTBoEfW2kzGAjmLkkOuk8ZuDmJoDCTMTmt+ArvF08X5bNmUgtiXdNjHL0SQ==
X-Received: by 2002:a24:8d03:: with SMTP id w3mr5363991itd.103.1554227156295;
        Tue, 02 Apr 2019 10:45:56 -0700 (PDT)
X-Received: by 2002:a24:8d03:: with SMTP id w3mr5363922itd.103.1554227155448;
        Tue, 02 Apr 2019 10:45:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554227155; cv=none;
        d=google.com; s=arc-20160816;
        b=Tvye+YaqsJWxTqIXYwgF9pbuv+4gHDcdFA/pr0Zy0XLCuEvoyIwRtqtTvusDeOIYuX
         /SF5Jcb22B+fIslxrTjVeYqOOlSZMj8N6E5h/d4+oiUEI1pav9Ai6eeQlVaMeb4+sNfg
         TI0EA18auT7edNPIUxNO7klSFlcAbQPArmZfnYt0Ld2vxfpv3Gmc4y/MMYrZ75SvIbI4
         d3HBfIjKmGVpjh9BCtKe/s7UXb4Z/l7uCU9Odl4ku94bDb/J8ULB6IMx/xHkdmI9CI10
         IQGBO/yfXJuTBMXU/GLEmRMdZWFaikvsmgFtGzN7zInFGvFZem+eZbm6czlSHNIVX7xX
         lrOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=v5t/Y4J0o1SK+hPA+fwYsPBbjhkFvdldj8PMZh7RPww=;
        b=JcbtbMslxxRPvaMrJNM+g9EsGDxAV4A+YrtjaSvnC5ReW85aQoVPE6RdbAqGQ5u7JK
         uC1O9E9vKo6+mdXct91zUDgmMAkjo/Jij4gNm7/vsu5oXqWOYO60hFBBOx8WFWSHyK5x
         Juz31jqvmadJJcd5Gtz093lu/D+PbewVjDGDHMyI4bzKZa9DcxY2CDqK0YQIth2kaDt3
         sIsvsCjzU3F4LQhMjtEx6oG1h1///aBPEoOXWNpMzwY0P3LjBH79kuOFlFzMtGmNv37c
         vFaB+bHnmSd/W+9UP0pkknzp6LbcmZ0YFeHoymtKMmJbgmzMy5kq9iXkvdNM0qgq7T9r
         RWlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YUSx16IW;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o129sor21045924ito.24.2019.04.02.10.45.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 10:45:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YUSx16IW;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=v5t/Y4J0o1SK+hPA+fwYsPBbjhkFvdldj8PMZh7RPww=;
        b=YUSx16IWi0/OQfL04ZDUpWfehULQqBrVTYISDNcZJ7e5LsS4DL8qHHYsRvhp9FziCe
         SA3nLjhz2BrlaVkpKwn7MW/XfnMBHvP+jwmxBvydQF14ePa0gKtS637eds6jdUeVU3X7
         SzHkAfnzicMmvFDS1owUbcpkYduYOFkld/8y0RE+QRqtM/F7WaSvFJQO3W1xBCbVbNpO
         8WNuUqmlkOmWqLH2cceT5Kgc/WYkoGlVAxAHRgCYLRaEh2I+yAXTmbUsum2Rygzx21C1
         tkfunpB0jHPRE6DPQLLqjgdY6fmSA7zgbDnN3v6ZMlIFwjzqUxTgSlUPRNGHDAtzs3GM
         nO+g==
X-Google-Smtp-Source: APXvYqxlZVPpn8RzULpJBTdsc+/NqRS35BYQf4K2iWoFL2TO4wJzqNHWJnFX2NMFPWr9UIN1fMiHi9lKco9sNZgeN7o=
X-Received: by 2002:a24:7c52:: with SMTP id a79mr5627493itd.51.1554227154886;
 Tue, 02 Apr 2019 10:45:54 -0700 (PDT)
MIME-Version: 1.0
References: <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org> <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org> <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com> <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com> <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <20190402112115-mutt-send-email-mst@kernel.org> <3dd76ce6-c138-b019-3a43-0bb0b793690a@redhat.com>
 <CAKgT0Uc78NYnva4T+G5uas_iSnE_YHGz+S5rkBckCvhNPV96gw@mail.gmail.com> <6b0a3610-0e7b-08dc-8b5f-707062f87bea@redhat.com>
In-Reply-To: <6b0a3610-0e7b-08dc-8b5f-707062f87bea@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 2 Apr 2019 10:45:43 -0700
Message-ID: <CAKgT0UdHA66z1j=3H06AfgtiF4ThFdXwQ6i8p1MszdL2bRHeZQ@mail.gmail.com>
Subject: Re: On guest free page hinting and OOM
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 10:09 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 02.04.19 18:18, Alexander Duyck wrote:
> > n Tue, Apr 2, 2019 at 8:57 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> On 02.04.19 17:25, Michael S. Tsirkin wrote:
> >>> On Tue, Apr 02, 2019 at 08:04:00AM -0700, Alexander Duyck wrote:
> >>>> Basically what we would be doing is providing a means for
> >>>> incrementally transitioning the buddy memory into the idle/offline
> >>>> state to reduce guest memory overhead. It would require one function
> >>>> that would walk the free page lists and pluck out pages that don't
> >>>> have the "Offline" page type set,
> >>>
> >>> I think we will need an interface that gets
> >>> an offline page and returns the next online free page.
> >>>
> >>> If we restart the list walk each time we can't guarantee progress.
> >>
> >> Yes, and essentially we are scanning all the time for chunks vs. we get
> >> notified which chunks are possible hinting candidates. Totally different
> >> design.
> >
> > The problem as I see it is that we can miss notifications if we become
> > too backlogged, and that will lead to us having to fall back to
> > scanning anyway. So instead of trying to implement both why don't we
> > just focus on the scanning approach. Otherwise the only other option
> > is to hold up the guest and make it wait until the hint processing has
> > completed and at that point we are back to what is essentially just a
> > synchronous solution with batching anyway.
> >
>
> In general I am not a fan of "there might be a problem, let's try
> something completely different". Expect the unexpected. At this point, I
> prefer to think about easy solutions to eventual problems. not
> completely new designs. As I said, we've been there already.

The solution as we have is not "easy". There are a number of race
conditions contained within the code and it doesn't practically scale
when you consider we are introducing multiple threads in both the
isolation and returning of pages to/from the buddy allocator that will
have to function within the zone lock.

> Related to "falling behind" with hinting. If this is indeed possible
> (and I'd like to know under which conditions), I wonder at which point
> we no longer care about missed hints. If our guest as a lot of MM
> activity, could be that is good that we are dropping hints, because our
> guest is so busy, it will reuse pages soon again.

This is making a LOT of assumptions. There are a few scenarios that
can hold up hinting on the host side. One of the limitations of
madvise is that we have to take the mm read semaphore. So if something
is sitting on the write semaphore all of the hints will be blocked
until it is released.

> One important point is - I think - that free page hinting does not have
> to fit all possible setups. In certain environments it just makes sense
> to disable it. Or live with it not giving you "all the hints". E.g.
> databases that eat up all free memory either way. The other extreme
> would be a simple webserver that is mostly idle.

My concern is we are introducing massive buffer bloat in the mm
subsystem and it still has the potential for stalling VCPUs if we
don't have room in the VQs. We went through this back in the day with
networking. Adding more buffers is not the solution. The solution is
to have a way to gracefully recover and keep our hinting latency and
buffer bloat to a minimum.

> We are losing hitning of quite free memory already due to the MAX_ORDER
> - X discussion. Dropping a couple of other hints shouldn't really hurt.
> The question is, are there scenarios where we can completely screw up.

My concern is that it can hurt a ton. In my mind the target for a
feature like this is a guest that has something like an application
that will fire up a few times a day eat up a massive amount of memory,
and then free it all when it is done. Now if that application is
freeing a massive block of memory and for whatever reason the QEMU
thread that is translating our hint requests to madvise calls cannot
keep up then we are going to spend the next several hours with that
memory still assigned to an idle guest.

