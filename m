Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CA37C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 20:10:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 388BD2084F
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 20:10:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cGs6wyoU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 388BD2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B18846B0007; Mon,  8 Apr 2019 16:10:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC7796B0008; Mon,  8 Apr 2019 16:10:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99C396B000A; Mon,  8 Apr 2019 16:10:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76DAA6B0007
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 16:10:46 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id m192so573491ita.8
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 13:10:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xGOMFn+rezxFRKxiyM+PbtfR/Qnez3AUZpWsBoYu8Ns=;
        b=A73q6vI1hy5MN0eUev4WA0EaqKBsuyLUgzBPYmohL4QsYpTZ6YVKeRLqOUXJiX2pnK
         AjADQsxVCxbXuEyNZaRm1Kiae5B/RR5rUvlQC9OQdR4G2EiPKdnXSFiqfrDhn4W2Rf2m
         2oU2C/KGTd/mHxnbT91SYnaiBP00GVWpZE24j8vhsaH+wBLTNocFrVqD637MgvFOzSLU
         xlwfxu63gq4wy02+995gIARuxQ83j3fOCXngkHVCcVgeFPVEHgSn3djbWjR4yvN5OlqA
         HAz0/C8DCL1NIvwaN2pAcEL16x0wMbd7/xq/RaJxqw8/u7aP83F5fOCIuKodf/v7HneJ
         XqGg==
X-Gm-Message-State: APjAAAXj/p1nPSU7NbibMola/ZTGrumx1MTQo14BtQji1jW5/qa/Bm4d
	m+Y0+UGMcupQUosKyEcEVhAu9BtsO+Mkzwflvs2xNHZZ6PxvOWrSM492Pwz8KHEQ5CV4oo9E/AE
	/ICWnWs6JgWwYy/lbb5MBG2gToX6ejPLChplnlXsv5rFbKmKrdc15b45dCrJPuKS+Pg==
X-Received: by 2002:a5d:8ad8:: with SMTP id e24mr12975333iot.214.1554754246196;
        Mon, 08 Apr 2019 13:10:46 -0700 (PDT)
X-Received: by 2002:a5d:8ad8:: with SMTP id e24mr12975296iot.214.1554754245214;
        Mon, 08 Apr 2019 13:10:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554754245; cv=none;
        d=google.com; s=arc-20160816;
        b=FPPO96lA22mHJ1Vt4IZcE76VbQGIEH+l2JDsUSEo2M23zRiM9Cn4NMJAjNTHlfw6yn
         +XmOdkz8Y43wHZq1T9GuUip7eLA/l14/y83oYo8HkTIDMwm4NQsYqPuQCD7y1rvYaxJk
         BnEuhg/HMymXTeSwHwerEfzWkNv/J8UWWPxSqF062UEQqANicdGCap7B9jS9HtNGZIGS
         6rpf4bflJ1d1bIb92yv4ZBgvTfZ3+/MmHczjq0GGuOyyAM7os+lmaxaLaQo3NNtF3H2y
         OVIoeSczg1fZUwEBy3Rvm3gY6fEls1pDyyk/g5459IcL2/0s+yFcu+ocVzPFasTgTiaN
         p52g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xGOMFn+rezxFRKxiyM+PbtfR/Qnez3AUZpWsBoYu8Ns=;
        b=N3Ka+g9vjk4gXOD5Y2kd6B77Rpt+4WxwPo2o7CSMdHVOrpdfg8orTzslyTDJN5quzb
         DWgQHBt5UEsXM+8uutXqWbNWojrW5dAKqY4mMGeVnVWcVSOOjGxil0YprPebZSKR6To6
         aC/O3+yvsAYasRFmDVtEsCgxUCB3v1kHn3uU1a40XYsDdrGP8jWkTAz1BgmqfE2RA/mV
         KCt3SfVikn42FDEGsQ/4HeQJO1Cfa1mwMVS6C2j2M8HTi/nhWHWwV5seT8xVX9wjojU9
         AxwPhHJTfKLf0CfKZlRiqMYZbsz1l1z/9ZTF28ssf23O0ZIdGoyNNYJqK+6PjEtaPmQv
         fT8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cGs6wyoU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z200sor16147510itb.10.2019.04.08.13.10.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 13:10:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cGs6wyoU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xGOMFn+rezxFRKxiyM+PbtfR/Qnez3AUZpWsBoYu8Ns=;
        b=cGs6wyoUhIFUXHkoTGy9OA7IBYOUPpB1QjQBYX37OegMXKaU53jjpVFmDNwpxtR9DT
         4luF6CJ4/Alj9xa7gCXT4jsXNIm25saDpBSEQOzIyyaiiPrL2EeIEHO0x58LOpyH1PN1
         u67aSdysilklocGloEYApa2NMvk71bf07lvWfh6OzyWo+SVgT/Vt4XZboDBFbyMJSidJ
         5YnDhGf6pQgLZI2rOEIPa/ouUN0K1l+NrHgF9vKApNJW6js4ALumOg4ZLXnHo/VyaoEV
         zcuAqoUGPQCw0VhCHo9s9msGJkb+jljOKwO4VSQPAIHLsOGtDy7ZIy7bnKzjXsmKA8MZ
         bJzA==
X-Google-Smtp-Source: APXvYqxsCQfqpavM3ha+I1fUSVIb85aO5gKEcm9w9aVfwpEYam6SMtZ+EGZE20aJFY2ZYg64Yh+chR7Xi0nJJ+2ln/g=
X-Received: by 2002:a24:4d06:: with SMTP id l6mr19017548itb.140.1554754244720;
 Mon, 08 Apr 2019 13:10:44 -0700 (PDT)
MIME-Version: 1.0
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com> <CAKgT0UfbVS2iupbf4Dfp91PAdgHNHwZ-RNyL=mcPsS_68Ly_9Q@mail.gmail.com>
 <ef4c219f-6686-f5f6-fd22-d1da0b1720f3@redhat.com>
In-Reply-To: <ef4c219f-6686-f5f6-fd22-d1da0b1720f3@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 8 Apr 2019 13:10:32 -0700
Message-ID: <CAKgT0Ucp1nt4roC1xdZEMcD17TvJovsDKBdkRK6vA_4bUM8bdw@mail.gmail.com>
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

On Mon, Apr 8, 2019 at 11:40 AM David Hildenbrand <david@redhat.com> wrote:
>
> >>>
> >>> In addition we will need some way to identify which pages have been
> >>> hinted on and which have not. The way I believe easiest to do this
> >>> would be to overload the PageType value so that we could essentially
> >>> have two values for "Buddy" pages. We would have our standard "Buddy"
> >>> pages, and "Buddy" pages that also have the "Offline" value set in the
> >>> PageType field. Tracking the Online vs Offline pages this way would
> >>> actually allow us to do this with almost no overhead as the mapcount
> >>> value is already being reset to clear the "Buddy" flag so adding a
> >>> "Offline" flag to this clearing should come at no additional cost.
> >>
> >> Just nothing here that this will require modifications to kdump
> >> (makedumpfile to be precise and the vmcore information exposed from the
> >> kernel), as kdump only checks for the the actual mapcount value to
> >> detect buddy and offline pages (to exclude them from dumps), they are
> >> not treated as flags.
> >>
> >> For now, any mapcount values are really only separate values, meaning
> >> not the separate bits are of interest, like flags would be. Reusing
> >> other flags would make our life a lot easier. E.g. PG_young or so. But
> >> clearing of these is then the problematic part.
> >>
> >> Of course we could use in the kernel two values, Buddy and BuddyOffline.
> >> But then we have to check for two different values whenever we want to
> >> identify a buddy page in the kernel.
> >
> > Actually this may not be working the way you think it is working.
>
> Trust me, I know how it works. That's why I was giving you the notice.
>
> Read the first paragraph again and ignore the others. I am only
> concerned about makedumpfile that has to be changed.
>
> PAGE_OFFLINE_MAPCOUNT_VALUE
> PAGE_BUDDY_MAPCOUNT_VALUE
>
> Once you find out how these values are used, you should understand what
> has to be changed and where.

Ugh. Is there an official repo I am supposed to refer to for makedumpfile?

As far as the changes needed I don't think this would necessitate
additional exports. We could probably just get away with having
makedumpfile generate a new value by simply doing an "&" of the two
values to determine what an offline buddy would be. If need be I can
submit a patch for that. I find it kind of annoying that the kernel is
handling identifying these bits one way, and makedumpfile is doing it
another way. It should have been setup to handle this all the same
way.

>
> >>>
> >>> Lastly we would need to create a specialized function for allocating
> >>> the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
> >>> "Offline" pages. I'm thinking the alloc function it would look
> >>> something like __rmqueue_smallest but without the "expand" and needing
> >>> to modify the !page check to also include a check to verify the page
> >>> is not "Offline". As far as the changes to __free_one_page it would be
> >>> a 2 line change to test for the PageType being offline, and if it is
> >>> to call add_to_free_area_tail instead of add_to_free_area.
> >>
> >> As already mentioned, there might be scenarios where the additional
> >> hinting thread might consume too much CPU cycles, especially if there is
> >> little guest activity any you mostly spend time scanning a handful of
> >> free pages and reporting them. I wonder if we can somehow limit the
> >> amount of wakeups/scans for a given period to mitigate this issue.
> >
> > That is why I was talking about breaking nr_free into nr_freed and
> > nr_bound. By doing that I can record the nr_free value to a
> > virtio-balloon specific location at the start of any walk and should
> > know exactly now many pages were freed between that call and the next
> > one. By ordering things such that we place the "Offline" pages on the
> > tail of the list it should make the search quite fast since we would
> > just be always allocating off of the head of the queue until we have
> > hinted everything int he queue. So when we hit the last call to alloc
> > the non-"Offline" pages and shut down our thread we can use the
> > nr_freed value that we recorded to know exactly how many pages have
> > been added that haven't been hinted.
> >
> >> One main issue I see with your approach is that we need quite a lot of
> >> core memory management changes. This is a problem. I wonder if we can
> >> factor out most parts into callbacks.
> >
> > I think that is something we can't get away from. However if we make
> > this generic enough there would likely be others beyond just the
> > virtualization drivers that could make use of the infrastructure. For
> > example being able to track the rate at which the free areas are
> > cycling in and out pages seems like something that would be useful
> > outside of just the virtualization areas.
>
> Might be, but might be the other extreme, people not wanting such
> special cases in core mm. I assume the latter until I see a very clear
> design where such stuff has been properly factored out.

The only real pain point I am seeing right now is the assumptions
makedumpfile is currently making about how mapcount is being used to
indicate pagetype. If we patch it to fix it most of the other bits are
minor.

> >
> >> E.g. in order to detect where to queue a certain page (front/tail), call
> >> a callback if one is registered, mark/check pages in a core-mm unknown
> >> way as offline etc.
> >>
> >> I still wonder if there could be an easier way to combine recording of
> >> hints and one hinting thread, essentially avoiding scanning and some of
> >> the required core-mm changes.
> >
> > The concern I have with trying to avoid the scanning by tracking is
> > that if you fall behind it becomes something where just tracking the
> > metadata for the page hints would start to become expensive.
>
> Depends, if it is mostly only marking a bit in a bitmap, it should in
> general not be too much of an issue. As usual, the datastructure used is
> the important bit.

Right, but that is a shared bitmap. It means there is yet another
cacheline that will be touched for allocating and freeing pages and
that is going to add cost. That cost is even worse if we are talking
about using the existing setup that was only tracking the pages that
was freed and then having to search for the page buddy from the
original order up to MAX_ORDER - 1.

