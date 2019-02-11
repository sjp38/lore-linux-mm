Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27F9DC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:52:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEDE22184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:52:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEDE22184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6697F8E0185; Mon, 11 Feb 2019 17:52:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63CD78E017F; Mon, 11 Feb 2019 17:52:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52F348E0185; Mon, 11 Feb 2019 17:52:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24D3F8E017F
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:52:36 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c84so13877752qkb.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:52:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=11U4MWGrCzTQVbIO8BWgImJ801iBJrsjX7Cy+5UfKRU=;
        b=IbV0zrpZ1cwXIhCZr/FwZFG/qT+qjeyZQjRSLz7vUEN53MPulq7GCSwJx9ICMpwsCC
         kFZ8MnR8L73ziFjw27mOy75SI25C8hiyYhI4Pr3ZKt8hE8qmyxIvemmEIGVyKYXCMVdT
         LNCeLJK9uBq0abdCTKdF8hJXT+jlYh2IEdaKRaOKSQsEvXpDjurMwoLkXNy9WmhiSqWz
         Y5jI1gnwcyTW+XaapK1HhuvFp6A6nZ9mfumyeMYwB+qoqSak/iuh8EzCqkmcccnWzOB0
         wCUsU26Cd4pcoJ58ZO5fsW5b9YCgTHBpcBprRDWNJIby1/W1D3ADZ2qD6yqB0Qf4MDAy
         BxTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZMf1w8vg/JIXA7HxD1Qup+KJ6ec9zVAqvJz8lHfXpVER7Q8ktS
	VySQdJYz3MmjYDVA8o4fZZi2rlmGFm9k0ek8Qs270Xdgn6B9MGZJ1ApE1XCV/kEdqnzI7ycb4zd
	fJJzMO5STZa5CaSsr/GrCyafGRi3Mf2+V63mlDZzLe5kdBBu52mVL7P+dea311CqWcA==
X-Received: by 2002:ac8:8ca:: with SMTP id y10mr452330qth.153.1549925555823;
        Mon, 11 Feb 2019 14:52:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaGrpv8GAgZUh/J1+iiT9zPTVzlviLttsSYJOZQV0Sz64HJjenN2fbuh9UaWqQCeIKR90YA
X-Received: by 2002:ac8:8ca:: with SMTP id y10mr452302qth.153.1549925554997;
        Mon, 11 Feb 2019 14:52:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925554; cv=none;
        d=google.com; s=arc-20160816;
        b=khWvk6t8/ub3HCsvwyE0rtg7TeP1mD7tmABUG+97UuKjLlUHepLxrOURXy+jBNcyX2
         Y105XgtvgGMXhROUeQhz3kUBf+XiQbU7EbKNwuAxHv0A88xtDDE2NQkNsDE2OMAQXKEA
         bLjzYSWSGutN8HyQzMWqlljnu+4UY4yvOZyItEpiMxBoYcU9Rid9SqYRNbDC2kv8Pmhk
         yoolAfEniKKVu6So6sMAMo9YhBsPPVXmmC7fOAjKHAjcie5w6QerZnZTu2mnckdXhBzj
         sCLL4WMpweQUeJGEXoX1rOnYtDk5jShyjXZysjgzzSirKp7AIUcfAArcSQN9hkBV7Grh
         nVCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=11U4MWGrCzTQVbIO8BWgImJ801iBJrsjX7Cy+5UfKRU=;
        b=l/VjLhJcXIVjZN3BUdNaRme5CVtWcwI33tXT2BlMTW1ksazoADUPO2v7g1h/SCYlsm
         eWh0dLvW37tdj1rE/0lbrwnc2zAxb+WHcFba4LKLelY6HItWCXdpdA2WBSj2WYn/Wcap
         af+1xk6XhkVAoxfmKSqsDwqLrves/kfaAlN5C1NSF48QqG5jJrKcAgHAJGyVzYoIo3Mr
         YWh3EF2L5m1BRbdVvq7ltBIqJIFVPJahG0+5VxYjaJOQndaqlmq6dET02yNN8TltwHXR
         7+YjQrZdt9gJsswuQT0VVPBwXIvHxyCXAFB8T1m1w4EvksKE+PrzaMuCixRzTH8kTy1i
         h5DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g124si5368706qkc.76.2019.02.11.14.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:52:34 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 20ADA80F83;
	Mon, 11 Feb 2019 22:52:34 +0000 (UTC)
Received: from redhat.com (ovpn-121-111.rdu2.redhat.com [10.10.121.111])
	by smtp.corp.redhat.com (Postfix) with SMTP id D898D17CDD;
	Mon, 11 Feb 2019 22:52:30 +0000 (UTC)
Date: Mon, 11 Feb 2019 17:52:30 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
	hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
	akpm@linux-foundation.org
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
Message-ID: <20190211174256-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
 <20190209194437-mutt-send-email-mst@kernel.org>
 <869a170e9232ffbc8ddbcf3d15535e8c6daedbde.camel@linux.intel.com>
 <20190211122321-mutt-send-email-mst@kernel.org>
 <44d0848e62f6d5237b60d209265dbcdf58ade1b9.camel@linux.intel.com>
 <20190211142902-mutt-send-email-mst@kernel.org>
 <770615ef2db838775fb68130ca60711c6e593f3d.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <770615ef2db838775fb68130ca60711c6e593f3d.camel@linux.intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 11 Feb 2019 22:52:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 01:00:53PM -0800, Alexander Duyck wrote:
> On Mon, 2019-02-11 at 14:54 -0500, Michael S. Tsirkin wrote:
> > On Mon, Feb 11, 2019 at 10:10:06AM -0800, Alexander Duyck wrote:
> > > On Mon, 2019-02-11 at 12:36 -0500, Michael S. Tsirkin wrote:
> > > > On Mon, Feb 11, 2019 at 08:31:34AM -0800, Alexander Duyck wrote:
> > > > > On Sat, 2019-02-09 at 19:49 -0500, Michael S. Tsirkin wrote:
> > > > > > On Mon, Feb 04, 2019 at 10:15:52AM -0800, Alexander Duyck wrote:
> > > > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > > 
> > > > > > > Add guest support for providing free memory hints to the KVM hypervisor for
> > > > > > > freed pages huge TLB size or larger. I am restricting the size to
> > > > > > > huge TLB order and larger because the hypercalls are too expensive to be
> > > > > > > performing one per 4K page.
> > > > > > 
> > > > > > Even 2M pages start to get expensive with a TB guest.
> > > > > 
> > > > > Agreed.
> > > > > 
> > > > > > Really it seems we want a virtio ring so we can pass a batch of these.
> > > > > > E.g. 256 entries, 2M each - that's more like it.
> > > > > 
> > > > > The only issue I see with doing that is that we then have to defer the
> > > > > freeing. Doing that is going to introduce issues in the guest as we are
> > > > > going to have pages going unused for some period of time while we wait
> > > > > for the hint to complete, and we cannot just pull said pages back. I'm
> > > > > not really a fan of the asynchronous nature of Nitesh's patches for
> > > > > this reason.
> > > > 
> > > > Well nothing prevents us from doing an extra exit to the hypervisor if
> > > > we want. The asynchronous nature is there as an optimization
> > > > to allow hypervisor to do its thing on a separate CPU.
> > > > Why not proceed doing other things meanwhile?
> > > > And if the reason is that we are short on memory, then
> > > > maybe we should be less aggressive in hinting?
> > > > 
> > > > E.g. if we just have 2 pages:
> > > > 
> > > > hint page 1
> > > > page 1 hint processed?
> > > > 	yes - proceed to page 2
> > > > 	no - wait for interrupt
> > > > 
> > > > get interrupt that page 1 hint is processed
> > > > hint page 2
> > > > 
> > > > 
> > > > If hypervisor happens to be running on same CPU it
> > > > can process things synchronously and we never enter
> > > > the no branch.
> > > > 
> > > 
> > > Another concern I would have about processing this asynchronously is
> > > that we have the potential for multiple guest CPUs to become
> > > bottlenecked by a single host CPU. I am not sure if that is something
> > > that would be desirable.
> > 
> > Well with a hypercall per page the fix is to block VCPU
> > completely which is also not for everyone.
> > 
> > If you can't push a free page hint to host, then
> > ideally you just won't. That's a nice property of
> > hinting we have upstream right now.
> > Host too busy - hinting is just skipped.
> 
> Right, but if you do that then there is a potential to end up missing
> hints for a large portion of memory. It seems like you would end up
> with even bigger issues since then at that point you have essentially
> leaked memory.
> I would think you would need a way to resync the host and the guest
> after something like that. Otherwise you can have memory that will just
> go unused for an extended period if a guest just goes idle.

Yes and that is my point.  Existing hints code will just take a page off
the free list in that case so it resyncs using the free list.

Something like this could work then: mark up
hinted pages with a flag (its easy to find unused
flags for free pages) then when you get an interrupt
because outstanding hints have been consumed,
get unflagged/unhinted pages from buddy and pass
them to host.


> 
> > > > > > > Using the huge TLB order became the obvious
> > > > > > > choice for the order to use as it allows us to avoid fragmentation of higher
> > > > > > > order memory on the host.
> > > > > > > 
> > > > > > > I have limited the functionality so that it doesn't work when page
> > > > > > > poisoning is enabled. I did this because a write to the page after doing an
> > > > > > > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > > > > > > cycles to do so.
> > > > > > 
> > > > > > Again that's leaking host implementation detail into guest interface.
> > > > > > 
> > > > > > We are giving guest page hints to host that makes sense,
> > > > > > weird interactions with other features due to host
> > > > > > implementation details should be handled by host.
> > > > > 
> > > > > I don't view this as a host implementation detail, this is guest
> > > > > feature making use of all pages for debugging. If we are placing poison
> > > > > values in the page then I wouldn't consider them an unused page, it is
> > > > > being actively used to store the poison value.
> > > > 
> > > > Well I guess it's a valid point of view for a kernel hacker, but they are
> > > > unused from application's point of view.
> > > > However poisoning is transparent to users and most distro users
> > > > are not aware of it going on. They just know that debug kernels
> > > > are slower.
> > > > User loading a debug kernel and immediately breaking overcommit
> > > > is an unpleasant experience.
> > > 
> > > How would that be any different then a user loading an older kernel
> > > that doesn't have this feature and breaking overcommit as a result?
> > 
> > Well old kernel does not have the feature so nothing to debug.
> > When we have a new feature that goes away in the debug kernel,
> > that's a big support problem since this leads to heisenbugs.
> 
> Trying to debug host features from the guest would be a pain anyway as
> a guest shouldn't even really know what the underlying setup of the
> guest is supposed to be.

I'm talking about debugging the guest though.

> > > I still think it would be better if we left the poisoning enabled in
> > > such a case and just displayed a warning message if nothing else that
> > > hinting is disabled because of page poisoning.
> > > 
> > > One other thought I had on this is that one side effect of page
> > > poisoning is probably that KSM would be able to merge all of the poison
> > > pages together into a single page since they are all set to the same
> > > values. So even with the poisoned pages it would be possible to reduce
> > > total memory overhead.
> > 
> > Right. And BTW one thing that host can do is pass
> > the hinted area to KSM for merging.
> > That requires an alloc hook to free it though.
> > 
> > Or we could add a per-VMA byte with the poison
> > value and use that on host to populate pages on fault.
> > 
> > 
> > > > > If we can achieve this
> > > > > and free the page back to the host then even better, but until the
> > > > > features can coexist we should not use the page hinting while page
> > > > > poisoning is enabled.
> > > > 
> > > > Existing hinting in balloon allows them to coexist so I think we
> > > > need to set the bar just as high for any new variant.
> > > 
> > > That is what I heard. I will have to look into this.
> > 
> > It's not doing anything smart right now, just checks
> > that poison == 0 and skips freeing if not.
> > But it can be enhanced transparently to guests.
> 
> Okay, so it probably should be extended to add something like poison
> page that could replace the zero page for reads to a page that has been
> unmapped.
> 
> > > > > This is one of the reasons why I was opposed to just disabling page
> > > > > poisoning when this feature was enabled in Nitesh's patches. If the
> > > > > guest has page poisoning enabled it is doing something with the page.
> > > > > It shouldn't be prevented from doing that because the host wants to
> > > > > have the option to free the pages.
> > > > 
> > > > I agree but I think the decision belongs on the host. I.e.
> > > > hint the page but tell the host it needs to be careful
> > > > about the poison value. It might also mean we
> > > > need to make sure poisoning happens after the hinting, not before.
> > > 
> > > The only issue with poisoning after instead of before is that the hint
> > > is ignored and we end up triggering a page fault and zero as a result.
> > > It might make more sense to have an architecture specific call that can
> > > be paravirtualized to handle the case of poisoning the page for us if
> > > we have the unused page hint enabled. Otherwise the write to the page
> > > is a given to invalidate the hint.
> > 
> > Sounds interesting. So the arch hook will first poison and
> > then pass the page to the host?
> > 
> > Or we can also ask the host to poison for us, problem is this forces
> > host to either always write into page, or call MADV_DONTNEED,
> > without it could do MADV_FREE. Maybe that is not a big issue.
> 
> I would think we would ask the host to poison for us. If I am not
> mistaken both solutions right now are using MADV_DONTNEED. I would tend
> to lean that way if we are doing page poisoning since the cost for
> zeroing/poisoning the page on the host could be canceled out by
> dropping the page poisoning on the guest.
> 
> Then again since we are doing higher order pages only, and the
> poisoning is supposed to happen before we get into __free_one_page we
> would probably have to do both the poisoning, and the poison on fault.


Oh that's a nice trick. So in fact if we just make sure
we never report PAGE_SIZE pages then poisoning will
automatically happen before reporting?
So we just need to teach host to poison on fault.
Sounds cool and we can always optimize further later.

-- 
MST

