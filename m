Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D76BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:39:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D70F20684
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:39:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jFGijHMM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D70F20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEFFB8E0004; Fri,  8 Mar 2019 16:39:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9DB18E0002; Fri,  8 Mar 2019 16:39:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB5D48E0004; Fri,  8 Mar 2019 16:39:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 822018E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 16:39:49 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id p17so16333996ios.8
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 13:39:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ER81jMz6aYwks5XjM3dWpCRuuybUmD81uRR18RYI/cw=;
        b=PFEnZRejWAmQxizTGc02fAdP1HsuNEyOdJjOZmNG3lENIUdPKBMV8oXZbA3B/i9KQD
         X/n6Be4yB7/tvD8nzy2d6GJJSWljDbeZTppB4/L9u1yd8JLObAchAFfAqseL4CPAc7o1
         rD3kjKIzLNNGMsEoqE46i8JbAyYeFeRYyFwDZxPKD0LGCEmwUE8DU69aJFoMD9v6Y4F+
         fN9fmRWrm5qYn7PT1w5RY1OdCLto4OrJh6jskNPXJoVAv0GwtNMACZkVzDWMlTCE4JKO
         Yq8pxaVUEqTDqwggAIOjAn53Vl68FhC5rcMo1GKisNYW0/DkbgcdgCHEVTvBodXjKVCn
         mGvg==
X-Gm-Message-State: APjAAAXCVEgf+LuOl8sDOjuWikAGQTUskDujmf7ht0qW2rTyBG4JfcKn
	VmKmKysHNSxClX9BwCW24V7r5trYKzeabCQ4sNvYDUe3rRHvniQssV++tuIWZNSu6N6iiXuGB6a
	zat2ylKlKR0uq+ovC/9RjbpB7Of0WI2B/2mRSS47OKOGLJNcTsQ4N4cxEA0+I/jRDp4mNLv/qUm
	Dfy5nwEwYu5noSQTuC/r3NZr4zeA+NUEqR6eYApbzctKrIsmA6VwhR6NBqkkhlBzTAKT0hWIWl1
	lvfX3LRe+mf7jMSJXQFWaBLu8tiiMRFfkqtUBiBgDA9Kt0cNDXyYN1t95p1xX1XOGtO+Pu3IBPH
	z1cORdnY7HgkQUB6FviycPQ3JG1iwegTujx75TpBObBoxt/tFMQE9SsDugp6FfMTdyh/BFuCglw
	w
X-Received: by 2002:a02:9898:: with SMTP id q24mr11255524jaj.135.1552081189289;
        Fri, 08 Mar 2019 13:39:49 -0800 (PST)
X-Received: by 2002:a02:9898:: with SMTP id q24mr11255501jaj.135.1552081188233;
        Fri, 08 Mar 2019 13:39:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552081188; cv=none;
        d=google.com; s=arc-20160816;
        b=kJOIIMdxNZ9Zhp4J8emQJltSb1dg4hrQY9BAw4Cf7TeFW17nd2NV8gOq1sABhNiGyZ
         F6KaHHj0nBhY8vvAad7kHzhRXKfsXAVKGNjvteV9hTXau26pIIYc4ofcPgm7C4Gy8SLj
         01Kbu87EZFLDjfC53WxZsBeruhPVReeVmE1rIlrEdlEy5R57H3t5Rc+HCjEG+VAEvUmV
         2hvtPjJ6UNbZC2eZ1ZQjIB2NPyfC29wkUpPmCdasfyZTeuFR22P4Nru4v8eHyfYcUAke
         eSu/HPFdMVm58ZD8W9Jz2SWhLU4V1XLnkHN+PksqPBFF42j54WkWk+7f2QeNNZ1gLRa4
         RAig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ER81jMz6aYwks5XjM3dWpCRuuybUmD81uRR18RYI/cw=;
        b=Hlx/9jD/C5FTujKRfVT2LFjtijIh1CZ45j1LlYT/LmRFhuX/nF09egVZbsNk2HT0ag
         kdWkD5j9zID4hUIKX77JKGIZHu70pZ5pmDvnHQsoj9S+AN8GWPfxfp6GOqUTMBEd8YYP
         Hb5KTxs4CvNrDKjd2wXS89vDbpirctQQHssz44+FoJ8KYP9O27uOJRdsC06JDL8r2bvB
         hWUB6ha49bXoQ4Eyb16eB0PdKJ/8rrZo8Rnc4Yxj4z8q01E41HwB56XskuX3SKOzeCrt
         0MWF8JJxInm9Vj4tgVdpxxeYWyfWs2MjsqcJChaoSJ3vJVbUAAjzjkwQ2amUgNeQQUN7
         q4pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jFGijHMM;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v20sor53369iom.126.2019.03.08.13.39.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 13:39:48 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jFGijHMM;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ER81jMz6aYwks5XjM3dWpCRuuybUmD81uRR18RYI/cw=;
        b=jFGijHMME0wbRzZZpwiy4attIJJPudFqZM5x4Wyf3EOzMgh4yiNwwJSjLltr9csfl0
         mBDYYh6NF8Pqmm3mrLrVgD0255C7zC/O93EP4N9oJjPhV9DacnvYvByO+sf23+K2g5fw
         c+5u6mRjmQZ56epEkOT5yBaY9UWsVt2EOAs/Gky6t0A09Ycv+iZxy2df9mfFCRNZpp4q
         Lj68V7LWLMlSmocBcpFtOKtz4atLLd/0wH7XCQvFnNLglC6xKSCGPMN6d3Zb1EM2qYVZ
         wmNDVNoYDfcVsK5ra8djPn9uL6slxDnDFvtqIuWqShfcROZyFz2bbZ2g/NHwHFq1Xlyi
         dipg==
X-Google-Smtp-Source: APXvYqw39cp+/C3Zic+uI32cg/tlcNORWlBCMTiteau667jhCugVZWVLu1SuMidywbKgws1aBxMY+/I0bTPtTDXyirY=
X-Received: by 2002:a5e:8403:: with SMTP id h3mr1229443ioj.116.1552081187769;
 Fri, 08 Mar 2019 13:39:47 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com> <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com> <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org> <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com> <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
 <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com>
In-Reply-To: <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 8 Mar 2019 13:39:36 -0800
Message-ID: <CAKgT0UddT9CKg1uZo6ZODs9ARti-6XGm9Zvo+8QRZKUPSwzWMQ@mail.gmail.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free pages
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>, 
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

On Fri, Mar 8, 2019 at 11:39 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> On 3/8/19 2:25 PM, Alexander Duyck wrote:
> > On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>
> >> On 3/8/19 1:06 PM, Alexander Duyck wrote:
> >>> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >>>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> >>>>> The only other thing I still want to try and see if I can do is to add
> >>>>> a jiffies value to the page private data in the case of the buddy
> >>>>> pages.
> >>>> Actually there's one extra thing I think we should do, and that is make
> >>>> sure we do not leave less than X% off the free memory at a time.
> >>>> This way chances of triggering an OOM are lower.
> >>> If nothing else we could probably look at doing a watermark of some
> >>> sort so we have to have X amount of memory free but not hinted before
> >>> we will start providing the hints. It would just be a matter of
> >>> tracking how much memory we have hinted on versus the amount of memory
> >>> that has been pulled from that pool.
> >> This is to avoid false OOM in the guest?
> > Partially, though it would still be possible. Basically it would just
> > be a way of determining when we have hinted "enough". Basically it
> > doesn't do us much good to be hinting on free memory if the guest is
> > already constrained and just going to reallocate the memory shortly
> > after we hinted on it. The idea is with a watermark we can avoid
> > hinting until we start having pages that are actually going to stay
> > free for a while.
> >
> >>>  It is another reason why we
> >>> probably want a bit in the buddy pages somewhere to indicate if a page
> >>> has been hinted or not as we can then use that to determine if we have
> >>> to account for it in the statistics.
> >> The one benefit which I can see of having an explicit bit is that it
> >> will help us to have a single hook away from the hot path within buddy
> >> merging code (just like your arch_merge_page) and still avoid duplicate
> >> hints while releasing pages.
> >>
> >> I still have to check PG_idle and PG_young which you mentioned but I
> >> don't think we can reuse any existing bits.
> > Those are bits that are already there for 64b. I think those exist in
> > the page extension for 32b systems. If I am not mistaken they are only
> > used in VMA mapped memory. What I was getting at is that those are the
> > bits we could think about reusing.
> >
> >> If we really want to have something like a watermark, then can't we use
> >> zone->free_pages before isolating to see how many free pages are there
> >> and put a threshold on it? (__isolate_free_page() does a similar thing
> >> but it does that on per request basis).
> > Right. That is only part of it though since that tells you how many
> > free pages are there. But how many of those free pages are hinted?
> > That is the part we would need to track separately and then then
> > compare to free_pages to determine if we need to start hinting on more
> > memory or not.
> Only pages which are isolated will be hinted, and once a page is
> isolated it will not be counted in the zone free pages.
> Feel free to correct me if I am wrong.

You are correct up to here. When we isolate the page it isn't counted
against the free pages. However after we complete the hint we end up
taking it out of isolation and returning it to the "free" state, so it
will be counted against the free pages.

> If I am understanding it correctly you only want to hint the idle pages,
> is that right?

Getting back to the ideas from our earlier discussion, we had 3 stages
for things. Free but not hinted, isolated due to hinting, and free and
hinted. So what we would need to do is identify the size of the first
pool that is free and not hinted by knowing the total number of free
pages, and then subtract the size of the pages that are hinted and
still free.

> >
> >>>>> With that we could track the age of the page so it becomes
> >>>>> easier to only target pages that are truly going cold rather than
> >>>>> trying to grab pages that were added to the freelist recently.
> >>>> I like that but I have a vague memory of discussing this with Rik van
> >>>> Riel and him saying it's actually better to take away recently used
> >>>> ones. Can't see why would that be but maybe I remember wrong. Rik - am I
> >>>> just confused?
> >>> It is probably to cut down on the need for disk writes in the case of
> >>> swap. If that is the case it ends up being a trade off.
> >>>
> >>> The sooner we hint the less likely it is that we will need to write a
> >>> given page to disk. However the sooner we hint, the more likely it is
> >>> we will need to trigger a page fault and pull back in a zero page to
> >>> populate the last page we were working on. The sweet spot will be that
> >>> period of time that is somewhere in between so we don't trigger
> >>> unnecessary page faults and we don't need to perform additional swap
> >>> reads/writes.
> >> --
> >> Regards
> >> Nitesh
> >>
> --
> Regards
> Nitesh
>

