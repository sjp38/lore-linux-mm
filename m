Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE56EC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:09:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88BEB2184A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:09:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88BEB2184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B06D8E019E; Mon, 11 Feb 2019 19:09:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05F578E019C; Mon, 11 Feb 2019 19:09:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E90288E019E; Mon, 11 Feb 2019 19:09:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1FF98E019C
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:09:55 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 59so635893plc.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:09:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FeJh5xzPnEwQx6wKcxYj16fqd0vuCa+MBNlXU3M35KU=;
        b=FIQ5bzHSePv6ulVWVNoE2LPgXupH3NR7wwj3AQqW8e4eY7rEqv+QFfxnaFvaRGrJ3B
         9CQ69x69pyL6nKPy34guWusqUHdrV6TS2at1LaD/iy8Ivq69zB5NWrI2GVMIfxEnX7rV
         ylann/yXjxkLRbCa5vgEGJrtZvpWLTVxgPgBO85l0KMT/KhhjtVj9TjvoZ40mthsGyN9
         c4f5rl8LQZX8sBrJv9q892g3kf1U9iBPxPlgZEFm499vJhibgQ0o/Zt30e4yGlRlnMa4
         UyM/koc/pIq1CX2Ij+Abeg3CQYJPSMgJbdlYxgnxZ4ttHQn7XSKC6hmAG1C7LqxSLQWu
         iNNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYSXwdPe2gej/96HHiiFyc4/BmthzryCSzPIBias1gCb5Nfbkri
	JAx5ZQwDIROchPSbZasOT4GnsdlNQMyga9VPSngBgVPNLZ3UwYThR0KCn3qPvkEEvt9cf/1DkLP
	msx8+3Gt5ffMOPsaItzB08BVptl0p7KhTHi64XQKaJUWLLN3z/dx/Mwnjf6MbMAOexQ==
X-Received: by 2002:a17:902:8f83:: with SMTP id z3mr973646plo.328.1549930195265;
        Mon, 11 Feb 2019 16:09:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY7IscRT3WIKs44e6R4aD++w0bJD+asbmT+n18lJAkkr6eR0zI+iyVmGvTpliQWXHeUPwh0
X-Received: by 2002:a17:902:8f83:: with SMTP id z3mr973564plo.328.1549930194154;
        Mon, 11 Feb 2019 16:09:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549930194; cv=none;
        d=google.com; s=arc-20160816;
        b=OKga7V+afCyR0zg61AZbJELP2zoG5svXdHUOf3cG2NaAPRdxcSrZdXg7Z04kiy8hrd
         94CMsgAi3+R+t8jYeDC5VjWuev42SV6JrTH0Lhsrs/CdiaNKSNglNXbpgGncwSSGObR3
         UPJUBjuKB9zCJWsUbzi3qKpITKbzkLJgjqz9mVOZmKZpPCTJ13d51kZp9ziQVCbm6aUp
         rklpnr0ylGKjXarSJEsEjG2Tt8mZVLZHBj/OK4ZoCcGbjZwlWi7rgC7/pKzIU9Qv9X0E
         PrOvtbW1lgD0YaYw9F3AQKpKB5eaFDJ3SH3nhOI0rUkWuG9VGsFKm3xh20tz9igZYi1t
         Qxow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=FeJh5xzPnEwQx6wKcxYj16fqd0vuCa+MBNlXU3M35KU=;
        b=KhpMuVGPHOXvxvWs9nVgnVmcyjqLfXy4gM2ISh0cf6Z+jgPmnA5rrc+Qrapo+NBj5I
         JbSmyQFv+gxBH38LU6zbPMm7lsBTmWxQLQdQlwr4kf2qBMZ2k6iM+DuWrovEsKb6Bssl
         HQaRkWRnXvQzkCt3SyZhqMHNA1LXuUJ08ApwbpRNRAVT/DuR0NLD3ivGruCjpW0n9trW
         poGWfwfp2fswBU1a5HFlkyPC02DiQt52qXekIoXENgA6rifi8vtdpvDia6+fYlgFOcyA
         YVWp9lIMnn3h2D+o1oeIOGJcPxr+DQQSJQstkZQKLgcJIW1ADnIAOQkqCx/BBxze726P
         WwJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f34si5292920ple.279.2019.02.11.16.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 16:09:54 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 16:09:53 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="125697129"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga003.jf.intel.com with ESMTP; 11 Feb 2019 16:09:53 -0800
Message-ID: <94462313ccd927d25675f69de459456cf066c1a2.camel@linux.intel.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, 
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, 
 x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
 pbonzini@redhat.com,  tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 11 Feb 2019 16:09:53 -0800
In-Reply-To: <20190211174256-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181552.12095.46287.stgit@localhost.localdomain>
	 <20190209194437-mutt-send-email-mst@kernel.org>
	 <869a170e9232ffbc8ddbcf3d15535e8c6daedbde.camel@linux.intel.com>
	 <20190211122321-mutt-send-email-mst@kernel.org>
	 <44d0848e62f6d5237b60d209265dbcdf58ade1b9.camel@linux.intel.com>
	 <20190211142902-mutt-send-email-mst@kernel.org>
	 <770615ef2db838775fb68130ca60711c6e593f3d.camel@linux.intel.com>
	 <20190211174256-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-11 at 17:52 -0500, Michael S. Tsirkin wrote:
> On Mon, Feb 11, 2019 at 01:00:53PM -0800, Alexander Duyck wrote:
> > On Mon, 2019-02-11 at 14:54 -0500, Michael S. Tsirkin wrote:
> > > On Mon, Feb 11, 2019 at 10:10:06AM -0800, Alexander Duyck wrote:
> > > > On Mon, 2019-02-11 at 12:36 -0500, Michael S. Tsirkin wrote:
> > > > > On Mon, Feb 11, 2019 at 08:31:34AM -0800, Alexander Duyck wrote:
> > > > > > On Sat, 2019-02-09 at 19:49 -0500, Michael S. Tsirkin wrote:
> > > > > > > On Mon, Feb 04, 2019 at 10:15:52AM -0800, Alexander Duyck wrote:
> > > > > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > > > 
> > > > > > > > Add guest support for providing free memory hints to the KVM hypervisor for
> > > > > > > > freed pages huge TLB size or larger. I am restricting the size to
> > > > > > > > huge TLB order and larger because the hypercalls are too expensive to be
> > > > > > > > performing one per 4K page.
> > > > > > > 
> > > > > > > Even 2M pages start to get expensive with a TB guest.
> > > > > > 
> > > > > > Agreed.
> > > > > > 
> > > > > > > Really it seems we want a virtio ring so we can pass a batch of these.
> > > > > > > E.g. 256 entries, 2M each - that's more like it.
> > > > > > 
> > > > > > The only issue I see with doing that is that we then have to defer the
> > > > > > freeing. Doing that is going to introduce issues in the guest as we are
> > > > > > going to have pages going unused for some period of time while we wait
> > > > > > for the hint to complete, and we cannot just pull said pages back. I'm
> > > > > > not really a fan of the asynchronous nature of Nitesh's patches for
> > > > > > this reason.
> > > > > 
> > > > > Well nothing prevents us from doing an extra exit to the hypervisor if
> > > > > we want. The asynchronous nature is there as an optimization
> > > > > to allow hypervisor to do its thing on a separate CPU.
> > > > > Why not proceed doing other things meanwhile?
> > > > > And if the reason is that we are short on memory, then
> > > > > maybe we should be less aggressive in hinting?
> > > > > 
> > > > > E.g. if we just have 2 pages:
> > > > > 
> > > > > hint page 1
> > > > > page 1 hint processed?
> > > > > 	yes - proceed to page 2
> > > > > 	no - wait for interrupt
> > > > > 
> > > > > get interrupt that page 1 hint is processed
> > > > > hint page 2
> > > > > 
> > > > > 
> > > > > If hypervisor happens to be running on same CPU it
> > > > > can process things synchronously and we never enter
> > > > > the no branch.
> > > > > 
> > > > 
> > > > Another concern I would have about processing this asynchronously is
> > > > that we have the potential for multiple guest CPUs to become
> > > > bottlenecked by a single host CPU. I am not sure if that is something
> > > > that would be desirable.
> > > 
> > > Well with a hypercall per page the fix is to block VCPU
> > > completely which is also not for everyone.
> > > 
> > > If you can't push a free page hint to host, then
> > > ideally you just won't. That's a nice property of
> > > hinting we have upstream right now.
> > > Host too busy - hinting is just skipped.
> > 
> > Right, but if you do that then there is a potential to end up missing
> > hints for a large portion of memory. It seems like you would end up
> > with even bigger issues since then at that point you have essentially
> > leaked memory.
> > I would think you would need a way to resync the host and the guest
> > after something like that. Otherwise you can have memory that will just
> > go unused for an extended period if a guest just goes idle.
> 
> Yes and that is my point.  Existing hints code will just take a page off
> the free list in that case so it resyncs using the free list.
> 
> Something like this could work then: mark up
> hinted pages with a flag (its easy to find unused
> flags for free pages) then when you get an interrupt
> because outstanding hints have been consumed,
> get unflagged/unhinted pages from buddy and pass
> them to host.

Ugh. This is beginning to sound like yet another daemon that will have
to be running to handle missed sync events.

I really think that taking an async approach for this will be nothing
but trouble. You are going to have a difficult time maintaining any
sort of coherency no the freelist without the daemon having to take the
zone lock and then notify the host of what is free and what isn't.

> > 
> > > > > > > > Using the huge TLB order became the obvious
> > > > > > > > choice for the order to use as it allows us to avoid fragmentation of higher
> > > > > > > > order memory on the host.
> > > > > > > > 
> > > > > > > > I have limited the functionality so that it doesn't work when page
> > > > > > > > poisoning is enabled. I did this because a write to the page after doing an
> > > > > > > > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > > > > > > > cycles to do so.
> > > > > > > 
> > > > > > > Again that's leaking host implementation detail into guest interface.
> > > > > > > 
> > > > > > > We are giving guest page hints to host that makes sense,
> > > > > > > weird interactions with other features due to host
> > > > > > > implementation details should be handled by host.
> > > > > > 
> > > > > > I don't view this as a host implementation detail, this is guest
> > > > > > feature making use of all pages for debugging. If we are placing poison
> > > > > > values in the page then I wouldn't consider them an unused page, it is
> > > > > > being actively used to store the poison value.
> > > > > 
> > > > > Well I guess it's a valid point of view for a kernel hacker, but they are
> > > > > unused from application's point of view.
> > > > > However poisoning is transparent to users and most distro users
> > > > > are not aware of it going on. They just know that debug kernels
> > > > > are slower.
> > > > > User loading a debug kernel and immediately breaking overcommit
> > > > > is an unpleasant experience.
> > > > 
> > > > How would that be any different then a user loading an older kernel
> > > > that doesn't have this feature and breaking overcommit as a result?
> > > 
> > > Well old kernel does not have the feature so nothing to debug.
> > > When we have a new feature that goes away in the debug kernel,
> > > that's a big support problem since this leads to heisenbugs.
> > 
> > Trying to debug host features from the guest would be a pain anyway as
> > a guest shouldn't even really know what the underlying setup of the
> > guest is supposed to be.
> 
> I'm talking about debugging the guest though.

Right. But my point is if it is a guest feature related to memory that
you are debugging, then disabling the page hinting would probably be an
advisable step anyway since it would have the potential for memory
corruptions itself due to its nature.

> > > > I still think it would be better if we left the poisoning enabled in
> > > > such a case and just displayed a warning message if nothing else that
> > > > hinting is disabled because of page poisoning.
> > > > 
> > > > One other thought I had on this is that one side effect of page
> > > > poisoning is probably that KSM would be able to merge all of the poison
> > > > pages together into a single page since they are all set to the same
> > > > values. So even with the poisoned pages it would be possible to reduce
> > > > total memory overhead.
> > > 
> > > Right. And BTW one thing that host can do is pass
> > > the hinted area to KSM for merging.
> > > That requires an alloc hook to free it though.
> > > 
> > > Or we could add a per-VMA byte with the poison
> > > value and use that on host to populate pages on fault.
> > > 
> > > 
> > > > > > If we can achieve this
> > > > > > and free the page back to the host then even better, but until the
> > > > > > features can coexist we should not use the page hinting while page
> > > > > > poisoning is enabled.
> > > > > 
> > > > > Existing hinting in balloon allows them to coexist so I think we
> > > > > need to set the bar just as high for any new variant.
> > > > 
> > > > That is what I heard. I will have to look into this.
> > > 
> > > It's not doing anything smart right now, just checks
> > > that poison == 0 and skips freeing if not.
> > > But it can be enhanced transparently to guests.
> > 
> > Okay, so it probably should be extended to add something like poison
> > page that could replace the zero page for reads to a page that has been
> > unmapped.
> > 
> > > > > > This is one of the reasons why I was opposed to just disabling page
> > > > > > poisoning when this feature was enabled in Nitesh's patches. If the
> > > > > > guest has page poisoning enabled it is doing something with the page.
> > > > > > It shouldn't be prevented from doing that because the host wants to
> > > > > > have the option to free the pages.
> > > > > 
> > > > > I agree but I think the decision belongs on the host. I.e.
> > > > > hint the page but tell the host it needs to be careful
> > > > > about the poison value. It might also mean we
> > > > > need to make sure poisoning happens after the hinting, not before.
> > > > 
> > > > The only issue with poisoning after instead of before is that the hint
> > > > is ignored and we end up triggering a page fault and zero as a result.
> > > > It might make more sense to have an architecture specific call that can
> > > > be paravirtualized to handle the case of poisoning the page for us if
> > > > we have the unused page hint enabled. Otherwise the write to the page
> > > > is a given to invalidate the hint.
> > > 
> > > Sounds interesting. So the arch hook will first poison and
> > > then pass the page to the host?
> > > 
> > > Or we can also ask the host to poison for us, problem is this forces
> > > host to either always write into page, or call MADV_DONTNEED,
> > > without it could do MADV_FREE. Maybe that is not a big issue.
> > 
> > I would think we would ask the host to poison for us. If I am not
> > mistaken both solutions right now are using MADV_DONTNEED. I would tend
> > to lean that way if we are doing page poisoning since the cost for
> > zeroing/poisoning the page on the host could be canceled out by
> > dropping the page poisoning on the guest.
> > 
> > Then again since we are doing higher order pages only, and the
> > poisoning is supposed to happen before we get into __free_one_page we
> > would probably have to do both the poisoning, and the poison on fault.
> 
> 
> Oh that's a nice trick. So in fact if we just make sure
> we never report PAGE_SIZE pages then poisoning will
> automatically happen before reporting?
> So we just need to teach host to poison on fault.
> Sounds cool and we can always optimize further later.

That is kind of what I was thinking. In the grand scheme of things I
figure most of the expense is in the fault and page zeroing bits of the
code path. I have done a bit of testing today with the patch that just
drops the messages if a device is assigned, and just the hypercall bits
are only causing about a 2.5% regression in performance on a will-it-
scale/page-fault1 test. However if I commit to the full setup with the
madvise, page fault, and zeroing then I am seeing an 11.5% drop in
performance.

I think in order to really make this pay off we may need to look into
avoiding zeroing or poisoning the page in both the host and the guest.
I will have to look into some things as it looks like there was
somebody from Intel may have been working on doing some work to address
that based on the presentation I found at the link below:

https://www.lfasiallc.com/wp-content/uploads/2017/11/Use-Hyper-V-Enlightenments-to-Increase-KVM-VM-Performance_Density_Chao-Peng.pdf
 

