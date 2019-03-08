Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D550AC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:25:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 817C1205C9
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:25:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kCAHH6u7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 817C1205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F2348E0004; Fri,  8 Mar 2019 14:25:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A2368E0002; Fri,  8 Mar 2019 14:25:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BA068E0004; Fri,  8 Mar 2019 14:25:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id D60998E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 14:25:43 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id x9so12570987ite.1
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 11:25:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eueI81hlBHIuacQFPrxPl4yBGSWnkJP7iRQaYgzjEZU=;
        b=nwXZ90fzCnPxh9+x0lgXzfpZFW+Z7DW0jSDAUA4BfOTB0so3btgcm2Uja2IYUwN6qo
         QWEYiqefNvAL06TW/u1XH1HYv4F7cXDYyWF0yIBzjU46b8uz0zkLMZvEsNzEGU2mJ7Uw
         4GonGS7R3h3erM9KFQo1s0lWBzpCSSBhmguf2/pClPmQDWiYUOr2yWjdfhVxVboIa99l
         cd14aBFaLaKG/Qf3HUthsYyNLww36GXoA1CK6IcRm0r42+Sy4QgJDzx3n+gCdLY1N5l6
         HjpCoj587gwcSR7tCd3J06tHx7PgCic0MlBZ/pigDsdegFVMOWOAhRsSydpKdxxVo1VX
         9aIg==
X-Gm-Message-State: APjAAAVUl4XgwJsx4Z0fWsRVQrbvH/edbvVBAQ382wmhL7iK3vIEou4p
	pRU3qqBges/Gct/YWbA/YnIMYT1GPYMKckd3vWlaybUs4qZVNmveEhZhB5LuF1t2kkQtPgBPMXl
	+bx9wnBvtZVgo3dQxlcJw64KC7IvC4mmwtX9s/9volT/o4y1JAyqnHdFI+oZPOh4LzGiCuqv2b3
	N9er0EXYIJSvHS0VSb18iSC/YVhaLXQu9on1PXHTEzM+i3p09r4C3/8x00U8tXe0mkmgUhtpD/I
	k+n0gpdZQrgJrmfksowUATrY6iVZ+kEiOpNK9wQv4g8eNt2bBq4rM0D1LTQUi5lIaI7mLmxcR2G
	+XBoXty1EPZg8+loQgDrZ4VmzkSRtwdolOFEsSjcw7hXlnqQV+sDBXTcBvQ/Om0h8FITGgRmhr2
	Q
X-Received: by 2002:a02:cd29:: with SMTP id h9mr3962586jaq.17.1552073143591;
        Fri, 08 Mar 2019 11:25:43 -0800 (PST)
X-Received: by 2002:a02:cd29:: with SMTP id h9mr3962555jaq.17.1552073142745;
        Fri, 08 Mar 2019 11:25:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552073142; cv=none;
        d=google.com; s=arc-20160816;
        b=bhAcOxM+PK6oR7Kwq3eS++AmFs058uustyB+ywa3O3KBta7XN4GkyFH47vRizYLvtN
         n8AgPhE88gX75vgb7HweqXdaPa5tRV6I2fA/lvJofzwnvK3qKw7xE3JOyE3AX2LitTXl
         5Yi7bTSOHRV9AnPqayjFrkA4NYal//che38/uJ5W6PjOEa9oF8qpsp6+fwCxxgK9FLOY
         bJpo4t0fbM8iWzrQZLN/AHBThCcGwUc/fNGB2yDIF/+6VQbpy3dVOXRgOjSW/WuOVZYI
         pccA4qr7S0dFdIle+D6NXndyeWc4e1C4RkodKdRM1quNBqujS5EmUi6JSC43TGDsVwIh
         wkAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eueI81hlBHIuacQFPrxPl4yBGSWnkJP7iRQaYgzjEZU=;
        b=bzZACefSj0DPqYLrk038A+2gS9t22ay+tKtDznNUJ65RC3Bxp027DJBjatW6oOxiDh
         1T+dadSjiE/C6dNpEqVfPZsP5orzeGKENz7MQlMxuyB2GNo4uKaUoTBvDES1OHd/ZwYv
         xuR25Y7Gqym/vC7dXBfyIwV5DJ2IH5L0fypbkpkspQGSoSjleO7sKFD+bbQGWDOkiQG8
         IH2RErkIuBIqyK3+8i58OI2od+Uh5IeOSipa0WBOSj2clpjXORnnsAd7N5X/WAQL9MUb
         1Tp5Z9q+q229pgfQ+AGfOjSDHsq1mGiiz1mXvpip59wTHOuJglHWK8ZECs+KYJI4OnZQ
         5zSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kCAHH6u7;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h16sor16368121itb.18.2019.03.08.11.25.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 11:25:42 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kCAHH6u7;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eueI81hlBHIuacQFPrxPl4yBGSWnkJP7iRQaYgzjEZU=;
        b=kCAHH6u7BKAg2v/KuzyA2DH6hNbkYeUI/3thPmb5A3ViR/Vk47IUVSM4pMGSB0iXq8
         2kybLU4POntOjOAiPspTXXzTKXhaZf1oDmhtCBrTFTc3Hcc4Uqfm58w1Z5QJ5kwINUO1
         JWYxYD/M8aV7OSDuX/IbF7vYbUNOTmI8SJ9xEV6Q09BqAXBn+8USIKCQDt6kT0kO9T3T
         bO7FdJ8OvAXo30UoKtBziksf+c5viXElvsZd7BWk1kYzCp4L9DWeKTblm9jzUNEsCTKM
         eG7dz0Ew7NJEhSa1kNr6W1Y6/DduftFlISDlWee0L/GNGCdtNztnYC2mmL/Pr64xirbL
         HnEQ==
X-Google-Smtp-Source: APXvYqwvM+nDA634dWrFenRaJiD7HjjtOxJXSCSWV4Tahrot/SOYsjh4JXXODre6DQKqpsfZy3IZ0SSO5JJ6gYZiFd0=
X-Received: by 2002:a24:45e3:: with SMTP id c96mr8763992itd.89.1552073142210;
 Fri, 08 Mar 2019 11:25:42 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com> <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com> <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org> <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com>
In-Reply-To: <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 8 Mar 2019 11:25:30 -0800
Message-ID: <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
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

On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> On 3/8/19 1:06 PM, Alexander Duyck wrote:
> > On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> >>> The only other thing I still want to try and see if I can do is to add
> >>> a jiffies value to the page private data in the case of the buddy
> >>> pages.
> >> Actually there's one extra thing I think we should do, and that is make
> >> sure we do not leave less than X% off the free memory at a time.
> >> This way chances of triggering an OOM are lower.
> > If nothing else we could probably look at doing a watermark of some
> > sort so we have to have X amount of memory free but not hinted before
> > we will start providing the hints. It would just be a matter of
> > tracking how much memory we have hinted on versus the amount of memory
> > that has been pulled from that pool.
> This is to avoid false OOM in the guest?

Partially, though it would still be possible. Basically it would just
be a way of determining when we have hinted "enough". Basically it
doesn't do us much good to be hinting on free memory if the guest is
already constrained and just going to reallocate the memory shortly
after we hinted on it. The idea is with a watermark we can avoid
hinting until we start having pages that are actually going to stay
free for a while.

> >  It is another reason why we
> > probably want a bit in the buddy pages somewhere to indicate if a page
> > has been hinted or not as we can then use that to determine if we have
> > to account for it in the statistics.
>
> The one benefit which I can see of having an explicit bit is that it
> will help us to have a single hook away from the hot path within buddy
> merging code (just like your arch_merge_page) and still avoid duplicate
> hints while releasing pages.
>
> I still have to check PG_idle and PG_young which you mentioned but I
> don't think we can reuse any existing bits.

Those are bits that are already there for 64b. I think those exist in
the page extension for 32b systems. If I am not mistaken they are only
used in VMA mapped memory. What I was getting at is that those are the
bits we could think about reusing.

> If we really want to have something like a watermark, then can't we use
> zone->free_pages before isolating to see how many free pages are there
> and put a threshold on it? (__isolate_free_page() does a similar thing
> but it does that on per request basis).

Right. That is only part of it though since that tells you how many
free pages are there. But how many of those free pages are hinted?
That is the part we would need to track separately and then then
compare to free_pages to determine if we need to start hinting on more
memory or not.

> >
> >>> With that we could track the age of the page so it becomes
> >>> easier to only target pages that are truly going cold rather than
> >>> trying to grab pages that were added to the freelist recently.
> >> I like that but I have a vague memory of discussing this with Rik van
> >> Riel and him saying it's actually better to take away recently used
> >> ones. Can't see why would that be but maybe I remember wrong. Rik - am I
> >> just confused?
> > It is probably to cut down on the need for disk writes in the case of
> > swap. If that is the case it ends up being a trade off.
> >
> > The sooner we hint the less likely it is that we will need to write a
> > given page to disk. However the sooner we hint, the more likely it is
> > we will need to trigger a page fault and pull back in a zero page to
> > populate the last page we were working on. The sweet spot will be that
> > period of time that is somewhere in between so we don't trigger
> > unnecessary page faults and we don't need to perform additional swap
> > reads/writes.
> --
> Regards
> Nitesh
>

