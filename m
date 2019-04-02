Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37AE1C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:18:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE306204EC
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:18:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PHnsUCSY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE306204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B4C06B000D; Tue,  2 Apr 2019 12:18:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 863406B0010; Tue,  2 Apr 2019 12:18:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 779F66B0269; Tue,  2 Apr 2019 12:18:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 578C66B000D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 12:18:32 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id v193so3286216itv.9
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 09:18:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Re+RFOGNndaiMDA2vDzD5LwdmPcg3nxlGPP85IpTjik=;
        b=ebn5cTBa9ztHxDHT91FNDKr/7rlaKug18OcplJguB9GgXR+Z7t19cpzhJKYBEKcKha
         kR1UlRNdUwEKZBm4A1QRUkvONr2DGr92CksD09+k/+XmhWx5tVswcehW8dCuqRlZyLfP
         wA03SnBtiq3kwYlV1YQFj1mvOX7TbFA92QZ4kPQ6kpnBP3x/DJFQfzpr+DTd3RkE6Wqv
         YoHdRdjjucRhq1bDJEXaX8dkKzUHcZycgAoigQNvUp7RG6k3G2KW75n8SzBBnWLGsc0q
         JlFKBXu/pWSL1Lhaysz9hBjYWnEta8udWdweUdiTosNcCi35kfJaqTqxmutqqs+hmSXD
         JNuQ==
X-Gm-Message-State: APjAAAWukf5iPTh/QWpX45YwhfNL+pboqw2DFwc5D0MK+K9bZh50tWqZ
	lFXSaAOCO7H+kD+WfGcqBPg19oVDptb8JYCDEBlZoao+wxmYUamrbhrbwhSez9O/QUIac4HcCJ9
	CKIyAsbyCT3bT3W0UV9rfuJ1YcVdW+lRJFxVEu69oY2s42Af5ibzUi0sDajmPM6bX1Q==
X-Received: by 2002:a02:9830:: with SMTP id t45mr53217842jaj.0.1554221912129;
        Tue, 02 Apr 2019 09:18:32 -0700 (PDT)
X-Received: by 2002:a02:9830:: with SMTP id t45mr53217776jaj.0.1554221911460;
        Tue, 02 Apr 2019 09:18:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554221911; cv=none;
        d=google.com; s=arc-20160816;
        b=kRnCsrZrEgwQ19we3Xjz/E/ZO5Qj+DgKteSPmQ4a3z5sQ5DKxkr8M1lm/CZHfIziOT
         x6osSmWCLEiEkkawzLtKT7WItBnSqYivcprTY47dQvsVyS5iSCXpQVeAaFu2W0YHGmLD
         pxTFM56WnZdnQHqTyOjChRT6+OLGCWzbwjR7qWMGfRVW9BBqn9oc7hMMH2X63g5UGgLW
         JvCAvhzpTvUjHhjag+kjLaiMG07I+17CfER3lZt4ODIljAUk8rIfx0dAId3r7vfYgU8h
         cHU1dsX2/OGQch/bUkXp2aYG2TK9KLJkDCVbD88fQtpcoyQ1ZF/OM5/6SzFhjCDUDOve
         1dvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Re+RFOGNndaiMDA2vDzD5LwdmPcg3nxlGPP85IpTjik=;
        b=zsNguLD2fwRhQ81qNKSUvy6n0CCOsb3B+1zOPHBBFtqeFMaU1LnyrcHWz1ynGGtqik
         8IpQA9ljV0DZxgfgf/3dGemf0BzTNcb1EKh0wXS2+WBWs2bHuUGasy9u97gu6A+Zijnm
         LBt7Hci0CHzAbJNx3aCFsxN3xUxqEZUCH4sl+Kp5rnMv3I9qPKOdY40Vm8KLKNzYTyLW
         ANWP25U/7fMTOv8q5XVBUjMwmksRYUaNiu9jkMBEBpFzyG7X6BZGd+eCGy8sSWoiFvVA
         WYsFEOJmzUg2hmKuf6vrTBhNeZhx+n4CEcYxQSMWBGJOoUXHBRhVLM33XVA+L9Qkmaef
         dHBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PHnsUCSY;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h12sor23638717itb.29.2019.04.02.09.18.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 09:18:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PHnsUCSY;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Re+RFOGNndaiMDA2vDzD5LwdmPcg3nxlGPP85IpTjik=;
        b=PHnsUCSY/qiykMhJ4pa9KK5JKO3Ze7zSHPJ79uUnDsBRGMw6hIDkR7+DcjMXQQYjPH
         nB7e1TsSudWHd8n1C4IYRhdkyNIXY5kUqyJ6zgVVQpaAmkoJV18cekhQhcPTXFFMnPTi
         t5dsHs3ikGRI5XwwZjWY4/kWN0GeLjJTzxCnOg51/Kkaop8NVvCmUixCZ538zIy9bRG7
         tcNmaT1ItOUct5VDhqjIS2/Z60StmPMOWOlROAXsP30qkFUeLdj3GIXCEQChdDb6EmcA
         9/2ta9d+qH7zKSOyNPXCZNc9lgyEcf6nOdr2EOgrYEJGPnN9Fkx3mDVDH3c2JUwzAqP7
         KY0g==
X-Google-Smtp-Source: APXvYqy3Rrz4CRj+wlX1B/s3NmvOSbnBxyJoOkkdOzK2bOS6mXJEXcERmnbqRdRmUCESfRrIxxTPqIyWF9egxW07qxY=
X-Received: by 2002:a02:c6d8:: with SMTP id r24mr5372138jan.93.1554221911086;
 Tue, 02 Apr 2019 09:18:31 -0700 (PDT)
MIME-Version: 1.0
References: <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org> <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org> <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com> <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com> <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <20190402112115-mutt-send-email-mst@kernel.org> <3dd76ce6-c138-b019-3a43-0bb0b793690a@redhat.com>
In-Reply-To: <3dd76ce6-c138-b019-3a43-0bb0b793690a@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 2 Apr 2019 09:18:19 -0700
Message-ID: <CAKgT0Uc78NYnva4T+G5uas_iSnE_YHGz+S5rkBckCvhNPV96gw@mail.gmail.com>
Subject: Re: On guest free page hinting and OOM
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

n Tue, Apr 2, 2019 at 8:57 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 02.04.19 17:25, Michael S. Tsirkin wrote:
> > On Tue, Apr 02, 2019 at 08:04:00AM -0700, Alexander Duyck wrote:
> >> Basically what we would be doing is providing a means for
> >> incrementally transitioning the buddy memory into the idle/offline
> >> state to reduce guest memory overhead. It would require one function
> >> that would walk the free page lists and pluck out pages that don't
> >> have the "Offline" page type set,
> >
> > I think we will need an interface that gets
> > an offline page and returns the next online free page.
> >
> > If we restart the list walk each time we can't guarantee progress.
>
> Yes, and essentially we are scanning all the time for chunks vs. we get
> notified which chunks are possible hinting candidates. Totally different
> design.

The problem as I see it is that we can miss notifications if we become
too backlogged, and that will lead to us having to fall back to
scanning anyway. So instead of trying to implement both why don't we
just focus on the scanning approach. Otherwise the only other option
is to hold up the guest and make it wait until the hint processing has
completed and at that point we are back to what is essentially just a
synchronous solution with batching anyway.

