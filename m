Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8259BC10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 21:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0894D20880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 21:56:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FIDKDkDk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0894D20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60DC96B000A; Mon,  8 Apr 2019 17:56:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BD076B000C; Mon,  8 Apr 2019 17:56:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC846B0010; Mon,  8 Apr 2019 17:56:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27E8C6B000A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 17:56:22 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id g184so859623ita.5
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 14:56:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WlaYw51ba8o+5WL0df316lF6GXkQeiMHb5j6EngoIN0=;
        b=ibak97dY5QxgXrUaIxa75F6FSQ5QE1kLsioIKQv0tNS70Imkbwa9J5L6DLGUV9jnvn
         EMqMi56ZfaYzvHxmr1BLCzA8iq8SVsqajRyaikO8C9heKHqYbl3XM8Nh2j3hQwj47et7
         CquuHhu3+2IE5FJ7f+PUt49fVn94AeDDkxB/wFmGEZzVk5bHtCMDbsPdCc59+g+0pdaz
         gnJxjTmc86XSNM8UpbubKrYqX9YJz4iGmCCXvoHt49uQzKYhfI1Yr77oGPWhecCfvvVR
         /mkIfWfOC6SUf7qCe9R+yBjysaxz7TLI40BXd0fjxhKpg9VKCnJgaQFhmyd2n+vJKOQ+
         mjHA==
X-Gm-Message-State: APjAAAX8HvdowBjdJdNlHRYzkWQZjzgM+Exm2wwjsvDWKrLCC+/q/tdw
	guOZnG1PeEUMSTELOZyWO5//HNKn7UGgjKB0skc+mAAdV4I7jJbhCLcF0pWpV7DQ3WONd9kIHW6
	j2N6P7S5Y29KBxusKR24xWBmU0n8A83/AI1A3jEng8/X9jMsCzEUnngV5Ka1eGLnq5g==
X-Received: by 2002:a02:a916:: with SMTP id n22mr22944036jam.40.1554760581849;
        Mon, 08 Apr 2019 14:56:21 -0700 (PDT)
X-Received: by 2002:a02:a916:: with SMTP id n22mr22943991jam.40.1554760580911;
        Mon, 08 Apr 2019 14:56:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554760580; cv=none;
        d=google.com; s=arc-20160816;
        b=obEIHpSdWU8jjhzAuV7slbsFTjgtuWns+ilUEAZpvzSYlc8er5RLYFt+K9/jVqZUMF
         W8kyrah8OvIgwpIYMmlHICtTWohaGRwMeVdA7MSSXsfhrPpbQgQIXc2uFydqsiVoE7ib
         7gXoT7Lhbw6viJLglA/mn3rTvKo9ubegiEk4r011AjaX8xCeLmLdHcbjGgZUFJj6py2I
         KSNTAmxJLf4vkBt/xLA+LKSVTaS84J4a26NpQvAweIPIhtBOilT/EJVQbRH1eA6oU0wV
         aBFl4JKuNP7Uv0YLWBRagjvLwszRDkheFcP5Xq134eJZfAwlSi9/V3egFhW/Eqb6rw29
         dSwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WlaYw51ba8o+5WL0df316lF6GXkQeiMHb5j6EngoIN0=;
        b=WSd/1+H3/qI/mujJLBEFovHJLCvYUVxd9n9glTgzMtd38UM7aGkpjs+ruz9ImEPYof
         NvPEydPaoOTBBmAUlEk2i2b14rMqEwDKRnee7bAr1HOa7fCZyW3oKcl59tANz2V/s/jE
         l8M5WXPFaKXZ88biXU6Ugd9PvVP0i1xS99He4qeVzlGjDdaLe55OQ7Q2I0CP/IJDZj1v
         KONycloG4kKiIo9cVSe6rjU/qi8V99Kwwvuf0lWQd918LFbfdwnnkgcEGVXCHj94/BE2
         SFcvMwLddF4P97dQ8BQrdJOTfptvnmIe8dD8+TuRCELvtxLLBvaTlZA7XW+YJVrI/rV1
         011Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FIDKDkDk;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v64sor16505581ita.35.2019.04.08.14.56.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 14:56:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FIDKDkDk;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WlaYw51ba8o+5WL0df316lF6GXkQeiMHb5j6EngoIN0=;
        b=FIDKDkDkd8iMIviZovj+I+OtFzEbzHrGP4RwSSA9Qtp6Wh495PTI/rHf07dDBZ/JW1
         7AT+cFzPUAQnWNUavkOhpBUz2piGIQ9AmSRXUrAqMP+JDJLmNCdqiCnSYUIVzevuFccn
         xbn2BkKch4iGvV00BNRYxcRugvhlKS/F++kx6vW3O+IxgbdlQ10E3wIFhRHuTh9dqkbR
         jwHhympS49chzhbhdcDfGcy9XsMQ0ttG/20o2LNtExO7NnnRFn+hz5oUaDLU/Afq2qhQ
         GGK1r5THXLjaoOACJ3q5tjVPuvt7WWa3RFKP4wO+sSvml9ZsMI4/JwoNeJ/ktLsFKC4H
         /Yng==
X-Google-Smtp-Source: APXvYqxnkG02zbOKRqiNAduEkkbnrhwIVSqN9LtpdyKaRX7jITYtRGFQDiXq+BDxA8Yzn6uwSBpTzDIt5qJwXv4G8sU=
X-Received: by 2002:a24:4d06:: with SMTP id l6mr19327875itb.140.1554760580453;
 Mon, 08 Apr 2019 14:56:20 -0700 (PDT)
MIME-Version: 1.0
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com> <CAKgT0UfbVS2iupbf4Dfp91PAdgHNHwZ-RNyL=mcPsS_68Ly_9Q@mail.gmail.com>
 <ef4c219f-6686-f5f6-fd22-d1da0b1720f3@redhat.com> <CAKgT0Ucp1nt4roC1xdZEMcD17TvJovsDKBdkRK6vA_4bUM8bdw@mail.gmail.com>
 <efe01b95-33d4-71ce-2a48-ec43f0846d68@redhat.com> <9da317cb-38ee-9b02-2549-65d8b45d5354@redhat.com>
In-Reply-To: <9da317cb-38ee-9b02-2549-65d8b45d5354@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 8 Apr 2019 14:56:09 -0700
Message-ID: <CAKgT0Uc=KbjCr_cX4GUbwqdJDXo45TAD6WcmwxD2D0Q48scRWw@mail.gmail.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting
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

On Mon, Apr 8, 2019 at 2:21 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 08.04.19 22:51, David Hildenbrand wrote:
> > On 08.04.19 22:10, Alexander Duyck wrote:
> >> On Mon, Apr 8, 2019 at 11:40 AM David Hildenbrand <david@redhat.com> wrote:
> >>>
> >>>>>>
> >>>>>> In addition we will need some way to identify which pages have been
> >>>>>> hinted on and which have not. The way I believe easiest to do this
> >>>>>> would be to overload the PageType value so that we could essentially
> >>>>>> have two values for "Buddy" pages. We would have our standard "Buddy"
> >>>>>> pages, and "Buddy" pages that also have the "Offline" value set in the
> >>>>>> PageType field. Tracking the Online vs Offline pages this way would
> >>>>>> actually allow us to do this with almost no overhead as the mapcount
> >>>>>> value is already being reset to clear the "Buddy" flag so adding a
> >>>>>> "Offline" flag to this clearing should come at no additional cost.
> >>>>>
> >>>>> Just nothing here that this will require modifications to kdump
> >>>>> (makedumpfile to be precise and the vmcore information exposed from the
> >>>>> kernel), as kdump only checks for the the actual mapcount value to
> >>>>> detect buddy and offline pages (to exclude them from dumps), they are
> >>>>> not treated as flags.
> >>>>>
> >>>>> For now, any mapcount values are really only separate values, meaning
> >>>>> not the separate bits are of interest, like flags would be. Reusing
> >>>>> other flags would make our life a lot easier. E.g. PG_young or so. But
> >>>>> clearing of these is then the problematic part.
> >>>>>
> >>>>> Of course we could use in the kernel two values, Buddy and BuddyOffline.
> >>>>> But then we have to check for two different values whenever we want to
> >>>>> identify a buddy page in the kernel.
> >>>>
> >>>> Actually this may not be working the way you think it is working.
> >>>
> >>> Trust me, I know how it works. That's why I was giving you the notice.
> >>>
> >>> Read the first paragraph again and ignore the others. I am only
> >>> concerned about makedumpfile that has to be changed.
> >>>
> >>> PAGE_OFFLINE_MAPCOUNT_VALUE
> >>> PAGE_BUDDY_MAPCOUNT_VALUE
> >>>
> >>> Once you find out how these values are used, you should understand what
> >>> has to be changed and where.
> >>
> >> Ugh. Is there an official repo I am supposed to refer to for makedumpfile?
> >>
> >> As far as the changes needed I don't think this would necessitate
> >> additional exports. We could probably just get away with having
> >> makedumpfile generate a new value by simply doing an "&" of the two
> >> values to determine what an offline buddy would be. If need be I can
> >> submit a patch for that. I find it kind of annoying that the kernel is
> >> handling identifying these bits one way, and makedumpfile is doing it
> >> another way. It should have been setup to handle this all the same
> >> way.
> >>
> >>>
> >>>>>>
> >>>>>> Lastly we would need to create a specialized function for allocating
> >>>>>> the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
> >>>>>> "Offline" pages. I'm thinking the alloc function it would look
> >>>>>> something like __rmqueue_smallest but without the "expand" and needing
> >>>>>> to modify the !page check to also include a check to verify the page
> >>>>>> is not "Offline". As far as the changes to __free_one_page it would be
> >>>>>> a 2 line change to test for the PageType being offline, and if it is
> >>>>>> to call add_to_free_area_tail instead of add_to_free_area.
> >>>>>
> >>>>> As already mentioned, there might be scenarios where the additional
> >>>>> hinting thread might consume too much CPU cycles, especially if there is
> >>>>> little guest activity any you mostly spend time scanning a handful of
> >>>>> free pages and reporting them. I wonder if we can somehow limit the
> >>>>> amount of wakeups/scans for a given period to mitigate this issue.
> >>>>
> >>>> That is why I was talking about breaking nr_free into nr_freed and
> >>>> nr_bound. By doing that I can record the nr_free value to a
> >>>> virtio-balloon specific location at the start of any walk and should
> >>>> know exactly now many pages were freed between that call and the next
> >>>> one. By ordering things such that we place the "Offline" pages on the
> >>>> tail of the list it should make the search quite fast since we would
> >>>> just be always allocating off of the head of the queue until we have
> >>>> hinted everything int he queue. So when we hit the last call to alloc
> >>>> the non-"Offline" pages and shut down our thread we can use the
> >>>> nr_freed value that we recorded to know exactly how many pages have
> >>>> been added that haven't been hinted.
> >>>>
> >>>>> One main issue I see with your approach is that we need quite a lot of
> >>>>> core memory management changes. This is a problem. I wonder if we can
> >>>>> factor out most parts into callbacks.
> >>>>
> >>>> I think that is something we can't get away from. However if we make
> >>>> this generic enough there would likely be others beyond just the
> >>>> virtualization drivers that could make use of the infrastructure. For
> >>>> example being able to track the rate at which the free areas are
> >>>> cycling in and out pages seems like something that would be useful
> >>>> outside of just the virtualization areas.
> >>>
> >>> Might be, but might be the other extreme, people not wanting such
> >>> special cases in core mm. I assume the latter until I see a very clear
> >>> design where such stuff has been properly factored out.
> >>
> >> The only real pain point I am seeing right now is the assumptions
> >> makedumpfile is currently making about how mapcount is being used to
> >> indicate pagetype. If we patch it to fix it most of the other bits are
> >> minor.
> >
> > I'll be curious how splitting etc. will be handled. Especially if you
> > want to set Offline for all affected sub pages.
> >
>
> Answering that myself, I guess you are planning to change the buddy to
> basically copy the offline value to sub-pages when splitting, also
> attaching them to the tail of the list instead of the head.

Yes that was the ultimate plan. I'm still debating the best place to
pull it from though. For now I am looking at just sampling the Offline
value before calling del_page_from_free_area as I had that currently
clearing the Offline flag when I was clearing the buddy. Then I was
just passing that to the expand function and having it set the Offline
flag.

Since expand is only called if the lower orders are empty there isn't
any point in adding to tail since the list is empty so head == tail
anyway.

