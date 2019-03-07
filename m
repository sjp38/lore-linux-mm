Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36E66C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:20:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5E9A20840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:20:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XSClPrMG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5E9A20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 780AB8E0003; Thu,  7 Mar 2019 17:20:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72F1E8E0002; Thu,  7 Mar 2019 17:20:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61DFF8E0003; Thu,  7 Mar 2019 17:20:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35C328E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 17:20:03 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id q184so10324273itd.6
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 14:20:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IGG5KSVzqw9klHrbU9eJgfJ/revtNroCGSHyb0jF2/c=;
        b=OSrdMPnupeLqr9gmUGPzRf2nZMC7DjhsB0I8itId9SEyErce8B7fmAh3m4cyTM9FwY
         RkjqCmNGmI5VaOdUD8Bnwm2MuCXVdb0w49ceDAp3+f7qao1ufrP5CKcsHlHeIenMGTGh
         oaqH1g1aMNQY7OiQF49iKSKwdJhxiKxUPd41+SqjM7K0nPOCcpASj/zzc7mlZmbfPhH5
         P4RngFd80zHXfi20EGIsgLhJcYh9P+FImLYV3NjXosLvwy3S2cN9btHoy433SL+Kgh3i
         P4J02EQrrMkjOKlJ89DQFJ0QKVy6G9EK3zxeqjgAylnMGS/3SLC8OI4rNtp3vrD7yy4M
         6dww==
X-Gm-Message-State: APjAAAXUy2XzJOwjwNubf3LIio3Gizv/E/H6AAf2dos5/OZeD5O+/wBs
	IcmocQagsBScpeTasJ2ecV/f01vjCvNbfJXM4Xlqr3gsmfnmunMlOqlIEFxSNfP22em1+PvrmsV
	jeEu1RScKPqqxPES6DaDippdeWoM23mJ1GIhB5y/pNM0Ih9BgcLP6tgIKmrtx0Uc2LbCvj2yoSi
	XqBlJQeCztqUO4A1tPS6yxMhIXTucFobOgsmN/5RqubtDBK0zyImlVNtstlwPLH3bjrNCb7IH0Y
	YHPXdjcxZDXOlBTbvVNVBUdPvlS7oqA1hk4u0FV0/dbSJNVKO4FlrakTXfLZb/CiD2XzHFzs5Sf
	//gcWmL4152OuTp+IogayCCIxDUHFPZwau2ghO/tDqU7tvNrUGVKB3elidYFgasEaIWI40lq+8T
	u
X-Received: by 2002:a6b:4402:: with SMTP id r2mr8252665ioa.247.1551997202980;
        Thu, 07 Mar 2019 14:20:02 -0800 (PST)
X-Received: by 2002:a6b:4402:: with SMTP id r2mr8252618ioa.247.1551997201896;
        Thu, 07 Mar 2019 14:20:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551997201; cv=none;
        d=google.com; s=arc-20160816;
        b=qnTyhh5NwiHXaB0td9+KXr5UWp5TUBI25GRvEr2Nh4TJQ2OdZlC+SfYDnBz0GhdBJ+
         EyWGpnqwRUMZpoumwE9XFvD/8zSdJ9myHJHfbBJON2lzLAIVVsEVmts1jwrEpIPyQSdG
         xo8NkE5fAO/yDcotqe1sPOLGxGVcz0mRCq4mETFsIG8LSfBVNFvNW+mbwUCpHyNI2dbk
         35+TG23xizCjpYM5aA+XUX0h2XE9M6feKRY3d49IPPY5V2Ci+Y8oIz6ZiX8682+2msjy
         nA4F75EV9baq1AEqO3RUPxU0hIWtjX2RaRs40JsYjIX4vhmVijxTBUetYIWjYJ53QeOK
         aWkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IGG5KSVzqw9klHrbU9eJgfJ/revtNroCGSHyb0jF2/c=;
        b=vCW/PPdEb4b7X1kbUoae4YZlxsDYzk4E3ugr840PexmXeFQThv83C1tp+qKp14m1UO
         bMnrwdiO0cdkhVeQ/MijFOMVD72wNC/hnl4PuOf9Dh21hwUDinFB9DMcpYmuTDUYcmuh
         kk1KMUpO5Q21ctq52lRfOfFVipPVwHR4Uc0hscpNqMumz74YUYWLG1WP90n87TjatRbP
         GYsCGFOWzCLVvZ/M7jqaQRKPNhmQ4RqNyaq61V4bivcCIfpK3GnSfl1Cgk1ZkoYwZ3CC
         vwNVj58YkWlTYKJycEBlH6xJoYHrx2pGK2ibjo0fNudkIPq16kMtserjIQlZU7IiIOHr
         1GFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XSClPrMG;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 72sor11006224itk.1.2019.03.07.14.20.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 14:20:01 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XSClPrMG;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IGG5KSVzqw9klHrbU9eJgfJ/revtNroCGSHyb0jF2/c=;
        b=XSClPrMGeqYhRsoAayUaHKY7sRoRHG8qxM+dxdtdFOsza6DMoeUz8Ou471+/kAix1B
         uD2qxtcJaqGTbcHiL88Tq2KcCJE/4w8rbM33dCoLZF+99BRDTpsQsQadvRBycpidXWUE
         NGS2JGdUIY5pQPBlQ0eXu5Vi+NODxKnXvEzI7EFlWA9RgUwB8GW07MvQfpTsJto0fnsG
         NtfEmYx22bQrJDnk+eQ9zh+c62MsX1CUiPmnqcKrb3Rj4khBn40IaSXE6p4/ePw+I/ja
         49LziZK3uiBaA31ZByjn+SU8MUzWkbcj5AsN9O9POH9rJdE04staRnDKmQrSW9pUuSU/
         sP+A==
X-Google-Smtp-Source: APXvYqyihToLlxeqd3iqbrWTUqWO+Y3E3cLh2rkZXQ6CZGZ3I7PTic6AK5KtNeYCQfuoWKtxOjCAmUdFkbCopwPFECA=
X-Received: by 2002:a24:4650:: with SMTP id j77mr6680197itb.6.1551997201407;
 Thu, 07 Mar 2019 14:20:01 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com> <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com> <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
 <20190307134744-mutt-send-email-mst@kernel.org> <CAKgT0Ue=Y-6-mzqzZ+tJYvfOd4ZeK59okeZKjfJ7LHwhbdpY_w@mail.gmail.com>
 <f15ccc0d-7c92-bab5-cc24-f49a4fea576f@redhat.com>
In-Reply-To: <f15ccc0d-7c92-bab5-cc24-f49a4fea576f@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 7 Mar 2019 14:19:50 -0800
Message-ID: <CAKgT0Uf2L43JtDMN+U8=-YKX6jjqjKwk_baXqLPwNj7p1K4LFA@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 1:28 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 07.03.19 22:14, Alexander Duyck wrote:
> > On Thu, Mar 7, 2019 at 10:53 AM Michael S. Tsirkin <mst@redhat.com> wrote:
> >>
> >> On Thu, Mar 07, 2019 at 10:45:58AM -0800, Alexander Duyck wrote:
> >>> To that end what I think w may want to do is instead just walk the LRU
> >>> list for a given zone/order in reverse order so that we can try to
> >>> identify the pages that are most likely to be cold and unused and
> >>> those are the first ones we want to be hinting on rather than the ones
> >>> that were just freed. If we can look at doing something like adding a
> >>> jiffies value to the page indicating when it was last freed we could
> >>> even have a good point for determining when we should stop processing
> >>> pages in a given zone/order list.
> >>>
> >>> In reality the approach wouldn't be too different from what you are
> >>> doing now, the only real difference would be that we would just want
> >>> to walk the LRU list for the given zone/order rather then pulling
> >>> hints on what to free from the calls to free_one_page. In addition we
> >>> would need to add a couple bits to indicate if the page has been
> >>> hinted on, is in the middle of getting hinted on, and something such
> >>> as the jiffies value I mentioned which we could use to determine how
> >>> old the page is.
> >>
> >> Do we really need bits in the page?
> >> Would it be bad to just have a separate hint list?
> >
> > The issue is lists are expensive to search. If we have a single bit in
> > the page we can check it as soon as we have the page.
> >
> >> If you run out of free memory you can check the hint
> >> list, if you find stuff there you can spin
> >> or kick the hypervisor to hurry up.
> >
> > This implies you are keeping a separate list of pages for what has
> > been hinted on. If we are pulling pages out of the LRU list for that
> > it will require the zone lock to move the pages back and forth and for
> > higher core counts that isn't going to scale very well, and if you are
> > trying to pull out a page that is currently being hinted on you will
> > run into the same issue of having to wait for the hint to be completed
> > before proceeding.
> >
> >> Core mm/ changes, so nothing's easy, I know.
> >
> > We might be able to reuse some existing page flags. For example, there
> > is the PG_young and PG_idle flags that would actually be a pretty good
> > fit in terms of what we are looking for in behavior. We could set
> > PG_young when the page is initially freed, then clear it when we start
> > to perform the hint, and set PG_idle once the hint has been completed.
>
> Just noting that when hinting, we have to set all affected sub-page bits
> as far as I see.

You may be correct there. One thing I hadn't thought about is what
happens if the page is split or merged up to a higher order. I guess I
could be talked into being okay with a side list that we maintain a
few pages in that are isolated from the rest.

> >
> > The check for if we could use a page would be pretty fast as a result
> > as well since if PG_young or PG_idle are set it means the page is free
> > to use so the check in arch_alloc_page would be pretty cheap since we
> > could probably test for both bits in one read.
> >
>
> I still dislike spinning on ordinary allocation paths. If we want to go
> that way, core mm has to consider these bits and try other pages first.

Agreed. I was just thinking that would be follow-on work since in my
mind the collision rate for these should be low.

