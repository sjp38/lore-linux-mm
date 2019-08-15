Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F6FCC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:25:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 137D72084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:25:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="DOotlbxS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 137D72084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A70186B02BA; Thu, 15 Aug 2019 12:25:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1F416B02BC; Thu, 15 Aug 2019 12:25:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90D0F6B02BD; Thu, 15 Aug 2019 12:25:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0114.hostedemail.com [216.40.44.114])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD316B02BA
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:25:29 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 08FA9640A
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:25:29 +0000 (UTC)
X-FDA: 75825187578.22.cow38_2fc6678d79a25
X-HE-Tag: cow38_2fc6678d79a25
X-Filterd-Recvd-Size: 5879
Received: from mail-oi1-f195.google.com (mail-oi1-f195.google.com [209.85.167.195])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:25:28 +0000 (UTC)
Received: by mail-oi1-f195.google.com with SMTP id p124so2650688oig.5
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:25:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wAN07Aej6p7Hd2hVE0xjo/DUiYqDdqV1ia2cD28NFxQ=;
        b=DOotlbxSe+oEc7h+VfeydF2jzAD8OEvRpE+Mg/T7l9NuSqDLgxqy80Rm7yaUhdlUsq
         XgZgOuBZPynYHO4pUyg0M+oxFE8PtShe6V/b9aN3W9gEmBvrEDd3jLri92IEvOnBd8yU
         d6tqu6UAtAcEGMC2AAWjeIO4ADYzS2PbO0fdY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=wAN07Aej6p7Hd2hVE0xjo/DUiYqDdqV1ia2cD28NFxQ=;
        b=C0oi9QOFoqXoS/NsLV62tvsxawMqIvNaYhJfTpdiKzymdnGqutnZdn6fvzR8ZFlUHT
         ZoHNDFnJx7Q5w656peHklHHws4nJceKrctWQCRfx5Iv/flZM2SdPS7qjNRZP2Pd5TAYp
         chnmA2AdozzWYEafsQ/poLParX7etyWSwz4DZN9ZloYG8V/+Ej4A034nHgP1Zc7/S5XI
         +1XIjymmdrOufuneaYAAXTHne7sanQ7r7DIICabBsbltSZhbH8KOR4WVqQt+RPcuvKdI
         WZx3KjDCtlXiCaSC+90gdFduRabHa5O2CKydSPeCfmkoQabKj4pLlThPYR+b+hj1bdbh
         QM8g==
X-Gm-Message-State: APjAAAX/4qVMApNSue0tOrSHKZiDKxlv0Ya7APi8oMccJrb6eY+RN9U9
	8rdR7dAHoG2y1j6qKWdo9Bkld1BbN+EcKxNJKV2cUw==
X-Google-Smtp-Source: APXvYqx5YhSWqsE1qNwb3e6Mk3OQ7+I0+E8yd7D6yMtzpx5rSV3pk3wPcLHj+cK8qGuWQRqpgPomSdRixh5Xeblp1Ps=
X-Received: by 2002:a54:4f89:: with SMTP id g9mr2267959oiy.110.1565886327298;
 Thu, 15 Aug 2019 09:25:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch> <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz> <20190815130415.GD21596@ziepe.ca>
 <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com>
 <20190815143759.GG21596@ziepe.ca> <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
 <20190815151028.GJ21596@ziepe.ca>
In-Reply-To: <20190815151028.GJ21596@ziepe.ca>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Thu, 15 Aug 2019 18:25:16 +0200
Message-ID: <CAKMK7uG33FFCGJrDV4-FHT2FWi+Z5SnQ7hoyBQd4hignzm1C-A@mail.gmail.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Peter Zijlstra <peterz@infradead.org>, 
	Ingo Molnar <mingo@redhat.com>, David Rientjes <rientjes@google.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Wei Wang <wvw@google.com>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Jann Horn <jannh@google.com>, Feng Tang <feng.tang@intel.com>, 
	Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 5:10 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Thu, Aug 15, 2019 at 04:43:38PM +0200, Daniel Vetter wrote:
>
> > You have to wait for the gpu to finnish current processing in
> > invalidate_range_start. Otherwise there's no point to any of this
> > really. So the wait_event/dma_fence_wait are unavoidable really.
>
> I don't envy your task :|
>
> But, what you describe sure sounds like a 'registration cache' model,
> not the 'shadow pte' model of coherency.
>
> The key difference is that a regirstationcache is allowed to become
> incoherent with the VMA's because it holds page pins. It is a
> programming bug in userspace to change VA mappings via mmap/munmap/etc
> while the device is working on that VA, but it does not harm system
> integrity because of the page pin.
>
> The cache ensures that each initiated operation sees a DMA setup that
> matches the current VA map when the operation is initiated and allows
> expensive device DMA setups to be re-used.
>
> A 'shadow pte' model (ie hmm) *really* needs device support to
> directly block DMA access - ie trigger 'device page fault'. ie the
> invalidate_start should inform the device to enter a fault mode and
> that is it.  If the device can't do that, then the driver probably
> shouldn't persue this level of coherency. The driver would quickly get
> into the messy locking problems like dma_fence_wait from a notifier.
>
> It is important to identify what model you are going for as defining a
> 'registration cache' coherence expectation allows the driver to skip
> blocking in invalidate_range_start. All it does is invalidate the
> cache so that future operations pick up the new VA mapping.
>
> Intel's HFI RDMA driver uses this model extensively, and I think it is
> well proven, within some limitations of course.
>
> At least, 'registration cache' is the only use model I know of where
> it is acceptable to skip invalidate_range_end.

I'm not really well versed in the details of our userptr, but both
amdgpu and i915 wait for the gpu to complete from
invalidate_range_start. Jerome has at least looked a lot at the amdgpu
one, so maybe he can explain what exactly it is we're doing ...
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

