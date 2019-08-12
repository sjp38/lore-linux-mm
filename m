Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DD7BC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:09:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 515AE214C6
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:09:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Kx0HfBYD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 515AE214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6FEB6B0007; Mon, 12 Aug 2019 12:09:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E20236B0008; Mon, 12 Aug 2019 12:09:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D363A6B000A; Mon, 12 Aug 2019 12:09:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0238.hostedemail.com [216.40.44.238])
	by kanga.kvack.org (Postfix) with ESMTP id B05056B0007
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:09:49 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 61171180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:09:49 +0000 (UTC)
X-FDA: 75814261698.17.heart98_1b7b7b69af243
X-HE-Tag: heart98_1b7b7b69af243
X-Filterd-Recvd-Size: 5501
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:09:48 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id k18so28683673otr.3
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:09:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QDjWy6zxgGdSDhJob+297Umxwr1TMxaLNkT4pYebqjI=;
        b=Kx0HfBYDrxN4e4uoSy1GSgWI+WokAnRWf3yS1svPrjsV8mHWlsmkRjzF3ANg5aSf6W
         ygJ33vA/pZC4kxseu9nRIlcpcIqW2wnn+3zborGy5gH+85Slm6/QOh10uhv29y70Mrko
         hnt+L7d/l104Bwmn8r992nsTM3uS1VICFBJDmh+eZnP1EuGDcIhsBgM8hX8q8Rnp6rRH
         Tu1sqknWU7+cm5j8m2cPdtcxQtwuyICiZ0X7p2uUVVQALBtMX9DzDxYOnQ+AaAwvySNi
         qDi20vU3RZzmgy3Xveef91D+ogyh+PJaC6Nr87pB3OPxtqjdQpa9ldvm/Kz4e6jLYG3U
         tDmA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=QDjWy6zxgGdSDhJob+297Umxwr1TMxaLNkT4pYebqjI=;
        b=WTXEhfvjeaVUJsycuoiIo+wrHm0VrS0slOTsX0+nymgGZaaGnieT9Coi0AybqegFo+
         a0jltwavMxv+NzRetU1Itjjem/l7SFBgRu2wepPhZ/Fh0k2Si91QONAAEwu5u1Liu3Vf
         Um7cXSpF0vltobw/HPUH/NQdwW974dHQxPZnorde8nDAgzKxMf4IpJrrFXtdbmI0G50u
         qJPXsk/QKZKD+9ZdbStTj6HRnadQH1uTIjmQ1fkUNgPGBh2FGlB5MEHJ/FHkoNytGnIv
         j7SvHlVoGE0eqmMFrYbYNCMeyv+FJrp05Ox6jKy3lnCeZouClzuZWtN6gUR8phIicnD+
         Lp2w==
X-Gm-Message-State: APjAAAWjU/W/YjWQUYwPFNvGuCcHn45LgMjEck2vzhRFL8iYB/uchuoZ
	GwlVMOK7gQXHDCxPw5yk4xcZsNxhtNPON2vHdU0=
X-Google-Smtp-Source: APXvYqwjCFQtckcxTzRGTeLLfqB5wY7X1qdlmFTvbdZpoH+ulXS1sqQPzBG21vx5nUc0Uvx1m3t9PDe8OKOcRfULw3E=
X-Received: by 2002:a6b:b549:: with SMTP id e70mr27581914iof.95.1565626187859;
 Mon, 12 Aug 2019 09:09:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190807224037.6891.53512.stgit@localhost.localdomain>
 <20190807224219.6891.25387.stgit@localhost.localdomain> <20190812055054-mutt-send-email-mst@kernel.org>
 <CAKgT0Ucr7GKWsP5sxSbDTtW_7puSqwXDM7y_ZD8i2zNrKNScEw@mail.gmail.com> <ddb2c4a9-c515-617f-770a-90625c08c829@redhat.com>
In-Reply-To: <ddb2c4a9-c515-617f-770a-90625c08c829@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 12 Aug 2019 09:09:36 -0700
Message-ID: <CAKgT0UekkEDPxDQ6J5uQZb92UDMq_fgHHo+tzGVP-jLWNAOp9w@mail.gmail.com>
Subject: Re: [PATCH v4 6/6] virtio-balloon: Add support for providing unused
 page reports to host
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
	Matthew Wilcox <willy@infradead.org>, lcapitulino@redhat.com, wei.w.wang@intel.com, 
	Andrea Arcangeli <aarcange@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, 
	Oscar Salvador <osalvador@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 8:50 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 12.08.19 17:20, Alexander Duyck wrote:
> > On Mon, Aug 12, 2019 at 2:53 AM Michael S. Tsirkin <mst@redhat.com> wrote:
> >>
> >> On Wed, Aug 07, 2019 at 03:42:19PM -0700, Alexander Duyck wrote:
> >>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >
> > <snip>
> >
> >>> --- a/include/uapi/linux/virtio_balloon.h
> >>> +++ b/include/uapi/linux/virtio_balloon.h
> >>> @@ -36,6 +36,7 @@
> >>>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM      2 /* Deflate balloon on OOM */
> >>>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT      3 /* VQ to report free pages */
> >>>  #define VIRTIO_BALLOON_F_PAGE_POISON 4 /* Guest is using page poisoning */
> >>> +#define VIRTIO_BALLOON_F_REPORTING   5 /* Page reporting virtqueue */
> >>>
> >>>  /* Size of a PFN in the balloon interface. */
> >>>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> >>
> >> Just a small comment: same as any feature bit,
> >> or indeed any host/guest interface changes, please
> >> CC virtio-dev on any changes to this UAPI file.
> >> We must maintain these in the central place in the spec,
> >> otherwise we run a risk of conflicts.
> >>
> >
> > Okay, other than that if I resubmit with the virtio-dev list added to
> > you thing this patch set is ready to be acked and pulled into either
> > the virtio or mm tree assuming there is no other significant feedback
> > that comes in?
> >
>
> I want to take a detailed look at the mm bits (might take a bit but I
> don't see a need to rush). I am fine with the page flag we are using.
> Hope some other mm people (cc'ing Michal and Oscar) can have a look.

Agreed. I just wanted to make sure we had the virtio bits locked in as
my concern was that some of the other MM maintainers might be waiting
on that.

I'll see about submitting a v5, hopefully before the end of today with
Michal, Oscar, and the virtio-dev mailing list also included.

Thanks.

- Alex

