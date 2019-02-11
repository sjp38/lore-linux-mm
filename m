Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D61AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:00:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C237C217D9
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:00:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C237C217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57F8B8E015F; Mon, 11 Feb 2019 16:00:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 530418E0155; Mon, 11 Feb 2019 16:00:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 445D38E015F; Mon, 11 Feb 2019 16:00:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 073078E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:00:56 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 2so190860pgg.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:00:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7q9lEGVKDheukUVIOFJiwmCt+DlpddVK+TDcNLRV+x8=;
        b=EEB6Nj+3QeM2VJyiCyVqoT+io0WllmO3Y7gUy4s6TQjCtvAZH2kQ546n0v7WXc60kJ
         igAs3OzB9XIQDvG9c8tKHUXcPPX8e/cSxudHmXFbYb1YcyIGhoPao/IfdMJ0yOGl0GE7
         1AzvRhqEyOcScqtUpjMvgzPKZyQs/SDQ96UvH/9BlA/DaerEFYMjtukgXZW5SVjkkflt
         XygkK4U3a00eepq1IBDgg34c1hmQoK4oFx/xMjJr7doXrmzgBz2wcC1CfCL9Dc8cOhyP
         kiEZIEL/owhcNEv9QfE4mKVnLtBDquEultyYbcm+CPTetxR3B3gbNIZuFLR3FyLA7DZv
         q2ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZnitQJdNrAqo/wwwBC9SNbsXtwyww4d2EVjGS9xLfbz+v6Q4gP
	vAc8TqRq0ShrBP4YCDpWMRTSN2Yr49RUyRVjLi8dxaID4k/vKsK0kx0O1j6f8VI42UrH3eqigLF
	boNUeXGeOPSvl87rnKy9Tb9qmm8ndrfCSV2S6w28/SHzp0Yno63xa6k34YG+iFYX5EQ==
X-Received: by 2002:a17:902:c23:: with SMTP id 32mr179409pls.183.1549918855667;
        Mon, 11 Feb 2019 13:00:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbkOWWh7X9h7O6RzBujuMoXiRF2rV7KIVvczjLG7n9/qfLrCEgItf6KiB8ecY7R+g2AsSqo
X-Received: by 2002:a17:902:c23:: with SMTP id 32mr179309pls.183.1549918854427;
        Mon, 11 Feb 2019 13:00:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549918854; cv=none;
        d=google.com; s=arc-20160816;
        b=vy3q4W9QwVp0JmNiPlvdh6UrFARa4SKsU0JnKzBTVC5czTrP3pQ54OyXYOsxjMJDCy
         WHoBI3fAd+9Zef7SZnrnbWH244eVC0be8mX02Tx4unvs4cO+0nv4ZsPGlzGXM+wRaJXV
         c12l3YSxXEQJNuub0IWm282P4vaDxKblPnBwLjO2BPKGT8hrNS9JR6a2VJUAMkuhhA0N
         HO5uS5T6Yx8OL1iYQe8Kwnk7o4pwLOjqlQrf9QBqfLY5Bp5Tw0MRp8yxnUzdRiijju8A
         nD13TCZx/AwDVDs+Qu6IyKtnF5sSIWggvnyxKDHWQQ2zqfSIG1PfsrsP/s7aPZcGWcjh
         EUqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=7q9lEGVKDheukUVIOFJiwmCt+DlpddVK+TDcNLRV+x8=;
        b=HCyXN5SmNs6l21QzRwNpckBSl2mwDHjNKihauW71tKBMLxQyx4dLxlrPc8PCxxNl9b
         x1ygxxUdrz19VSfvHFQn0baMMhIy6sFc2CmZEQmt6vmsF09iU8d6fkVRVvRW1DK5G8XC
         h3ETiat0gRIJegsfJqZ7VFJnxWtiomEKqGnEySEXDxjplzEc7yLreM3nNibAUSQFy0L+
         aiCHtBxMUAASytX5yFEti0NGDl1eZ6wWokA89/bs/dAUQ3HhLyXkhPpVU9KmsTY7BnvS
         qccs7ETpFc0+OkpUzaInnQVyRL2p3kjjQd3qtO3gG319Hiv+h3CRvOk2/h9jRw0TEop3
         KZ1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t13si8508953pgu.81.2019.02.11.13.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:00:54 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 13:00:53 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="133476917"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga002.jf.intel.com with ESMTP; 11 Feb 2019 13:00:53 -0800
Message-ID: <770615ef2db838775fb68130ca60711c6e593f3d.camel@linux.intel.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, 
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, 
 x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
 pbonzini@redhat.com,  tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 11 Feb 2019 13:00:53 -0800
In-Reply-To: <20190211142902-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181552.12095.46287.stgit@localhost.localdomain>
	 <20190209194437-mutt-send-email-mst@kernel.org>
	 <869a170e9232ffbc8ddbcf3d15535e8c6daedbde.camel@linux.intel.com>
	 <20190211122321-mutt-send-email-mst@kernel.org>
	 <44d0848e62f6d5237b60d209265dbcdf58ade1b9.camel@linux.intel.com>
	 <20190211142902-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-11 at 14:54 -0500, Michael S. Tsirkin wrote:
> On Mon, Feb 11, 2019 at 10:10:06AM -0800, Alexander Duyck wrote:
> > On Mon, 2019-02-11 at 12:36 -0500, Michael S. Tsirkin wrote:
> > > On Mon, Feb 11, 2019 at 08:31:34AM -0800, Alexander Duyck wrote:
> > > > On Sat, 2019-02-09 at 19:49 -0500, Michael S. Tsirkin wrote:
> > > > > On Mon, Feb 04, 2019 at 10:15:52AM -0800, Alexander Duyck wrote:
> > > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > 
> > > > > > Add guest support for providing free memory hints to the KVM hypervisor for
> > > > > > freed pages huge TLB size or larger. I am restricting the size to
> > > > > > huge TLB order and larger because the hypercalls are too expensive to be
> > > > > > performing one per 4K page.
> > > > > 
> > > > > Even 2M pages start to get expensive with a TB guest.
> > > > 
> > > > Agreed.
> > > > 
> > > > > Really it seems we want a virtio ring so we can pass a batch of these.
> > > > > E.g. 256 entries, 2M each - that's more like it.
> > > > 
> > > > The only issue I see with doing that is that we then have to defer the
> > > > freeing. Doing that is going to introduce issues in the guest as we are
> > > > going to have pages going unused for some period of time while we wait
> > > > for the hint to complete, and we cannot just pull said pages back. I'm
> > > > not really a fan of the asynchronous nature of Nitesh's patches for
> > > > this reason.
> > > 
> > > Well nothing prevents us from doing an extra exit to the hypervisor if
> > > we want. The asynchronous nature is there as an optimization
> > > to allow hypervisor to do its thing on a separate CPU.
> > > Why not proceed doing other things meanwhile?
> > > And if the reason is that we are short on memory, then
> > > maybe we should be less aggressive in hinting?
> > > 
> > > E.g. if we just have 2 pages:
> > > 
> > > hint page 1
> > > page 1 hint processed?
> > > 	yes - proceed to page 2
> > > 	no - wait for interrupt
> > > 
> > > get interrupt that page 1 hint is processed
> > > hint page 2
> > > 
> > > 
> > > If hypervisor happens to be running on same CPU it
> > > can process things synchronously and we never enter
> > > the no branch.
> > > 
> > 
> > Another concern I would have about processing this asynchronously is
> > that we have the potential for multiple guest CPUs to become
> > bottlenecked by a single host CPU. I am not sure if that is something
> > that would be desirable.
> 
> Well with a hypercall per page the fix is to block VCPU
> completely which is also not for everyone.
> 
> If you can't push a free page hint to host, then
> ideally you just won't. That's a nice property of
> hinting we have upstream right now.
> Host too busy - hinting is just skipped.

Right, but if you do that then there is a potential to end up missing
hints for a large portion of memory. It seems like you would end up
with even bigger issues since then at that point you have essentially
leaked memory.

I would think you would need a way to resync the host and the guest
after something like that. Otherwise you can have memory that will just
go unused for an extended period if a guest just goes idle.

> > > > > > Using the huge TLB order became the obvious
> > > > > > choice for the order to use as it allows us to avoid fragmentation of higher
> > > > > > order memory on the host.
> > > > > > 
> > > > > > I have limited the functionality so that it doesn't work when page
> > > > > > poisoning is enabled. I did this because a write to the page after doing an
> > > > > > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > > > > > cycles to do so.
> > > > > 
> > > > > Again that's leaking host implementation detail into guest interface.
> > > > > 
> > > > > We are giving guest page hints to host that makes sense,
> > > > > weird interactions with other features due to host
> > > > > implementation details should be handled by host.
> > > > 
> > > > I don't view this as a host implementation detail, this is guest
> > > > feature making use of all pages for debugging. If we are placing poison
> > > > values in the page then I wouldn't consider them an unused page, it is
> > > > being actively used to store the poison value.
> > > 
> > > Well I guess it's a valid point of view for a kernel hacker, but they are
> > > unused from application's point of view.
> > > However poisoning is transparent to users and most distro users
> > > are not aware of it going on. They just know that debug kernels
> > > are slower.
> > > User loading a debug kernel and immediately breaking overcommit
> > > is an unpleasant experience.
> > 
> > How would that be any different then a user loading an older kernel
> > that doesn't have this feature and breaking overcommit as a result?
> 
> Well old kernel does not have the feature so nothing to debug.
> When we have a new feature that goes away in the debug kernel,
> that's a big support problem since this leads to heisenbugs.

Trying to debug host features from the guest would be a pain anyway as
a guest shouldn't even really know what the underlying setup of the
guest is supposed to be.

> > I still think it would be better if we left the poisoning enabled in
> > such a case and just displayed a warning message if nothing else that
> > hinting is disabled because of page poisoning.
> > 
> > One other thought I had on this is that one side effect of page
> > poisoning is probably that KSM would be able to merge all of the poison
> > pages together into a single page since they are all set to the same
> > values. So even with the poisoned pages it would be possible to reduce
> > total memory overhead.
> 
> Right. And BTW one thing that host can do is pass
> the hinted area to KSM for merging.
> That requires an alloc hook to free it though.
> 
> Or we could add a per-VMA byte with the poison
> value and use that on host to populate pages on fault.
> 
> 
> > > > If we can achieve this
> > > > and free the page back to the host then even better, but until the
> > > > features can coexist we should not use the page hinting while page
> > > > poisoning is enabled.
> > > 
> > > Existing hinting in balloon allows them to coexist so I think we
> > > need to set the bar just as high for any new variant.
> > 
> > That is what I heard. I will have to look into this.
> 
> It's not doing anything smart right now, just checks
> that poison == 0 and skips freeing if not.
> But it can be enhanced transparently to guests.

Okay, so it probably should be extended to add something like poison
page that could replace the zero page for reads to a page that has been
unmapped.

> > > > This is one of the reasons why I was opposed to just disabling page
> > > > poisoning when this feature was enabled in Nitesh's patches. If the
> > > > guest has page poisoning enabled it is doing something with the page.
> > > > It shouldn't be prevented from doing that because the host wants to
> > > > have the option to free the pages.
> > > 
> > > I agree but I think the decision belongs on the host. I.e.
> > > hint the page but tell the host it needs to be careful
> > > about the poison value. It might also mean we
> > > need to make sure poisoning happens after the hinting, not before.
> > 
> > The only issue with poisoning after instead of before is that the hint
> > is ignored and we end up triggering a page fault and zero as a result.
> > It might make more sense to have an architecture specific call that can
> > be paravirtualized to handle the case of poisoning the page for us if
> > we have the unused page hint enabled. Otherwise the write to the page
> > is a given to invalidate the hint.
> 
> Sounds interesting. So the arch hook will first poison and
> then pass the page to the host?
> 
> Or we can also ask the host to poison for us, problem is this forces
> host to either always write into page, or call MADV_DONTNEED,
> without it could do MADV_FREE. Maybe that is not a big issue.

I would think we would ask the host to poison for us. If I am not
mistaken both solutions right now are using MADV_DONTNEED. I would tend
to lean that way if we are doing page poisoning since the cost for
zeroing/poisoning the page on the host could be canceled out by
dropping the page poisoning on the guest.

Then again since we are doing higher order pages only, and the
poisoning is supposed to happen before we get into __free_one_page we
would probably have to do both the poisoning, and the poison on fault.

