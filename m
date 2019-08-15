Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D6D3C3A59B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:49:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B69E02173E
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:49:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="YIJ7YIpM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B69E02173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B1666B0003; Thu, 15 Aug 2019 16:49:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 561E96B000A; Thu, 15 Aug 2019 16:49:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 476FC6B000C; Thu, 15 Aug 2019 16:49:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id 277236B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:49:45 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B8BA6180AD802
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:49:44 +0000 (UTC)
X-FDA: 75825853488.30.berry44_1ad2cd0c3a727
X-HE-Tag: berry44_1ad2cd0c3a727
X-Filterd-Recvd-Size: 4515
Received: from mail-oi1-f195.google.com (mail-oi1-f195.google.com [209.85.167.195])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:49:44 +0000 (UTC)
Received: by mail-oi1-f195.google.com with SMTP id y8so3228789oih.10
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:49:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lgnLIsY3NAF2I8cARaxRotDmNV7GudD+acm8febioSE=;
        b=YIJ7YIpMxznBPHgTdpSwquDHILTgLsnpo12EU8rkd+AHKFJZ5ZwqKoIwrRqaFSFR8y
         OSm/+kJt94YLyv2W7RB5Syzoulous/GPdyhQE4c6S/acM0xv4AIF2T1fqDaLkhBzGFIm
         8xguUk+swY546hiuNvL1kRCs6fhSMGv4cUMt8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=lgnLIsY3NAF2I8cARaxRotDmNV7GudD+acm8febioSE=;
        b=ULib2DUjqU8Gum5My3aCtApZlL2cuTxtVOcyUFi9o02zxoOK/kU+X5TaTSX4PCi/oU
         XDOLh19U8yGFLpFcU3mA2VSV12urY9ihbsVD0CiTTn02YTbO2zfDPVR9tpDzBXHplMiE
         +CHDjprXh0RAKRf2AfL9bF4YQ5JSFuyVBLGyWJ48dlMNc2gpJCbQI9cvP9foI10JCY3l
         g7BKrsOA+VvjO655PLs5Wycs2QVS631sFm9yhroBYd5K4m6tBi4hh3P2fIjBywUbMwWy
         3P0jAur2Dxge9p9GrSYSZxov4XFFap8zeuGNzTWJo+Z76AqQzQ03hXEJ3Njk0RNF0kgU
         PBJQ==
X-Gm-Message-State: APjAAAUuufsHsFM/fdg+OUzIzZiISk0OWMe9sHX7S2iOkWZL5fSnOJ34
	g+uAAyIwWjjJa3lV+WfRb4fWHVN/NPb2xspKvxW8zQ==
X-Google-Smtp-Source: APXvYqwzZ/kApGN6PiSs4Jakj+3xLiJKsdwsUzoZ79QigfmdRjFBzCS/DYJGNsj8cG6QhlWGKnUS/ZCe5UFKl5trWe8=
X-Received: by 2002:aca:4994:: with SMTP id w142mr2705861oia.132.1565902183316;
 Thu, 15 Aug 2019 13:49:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190815132127.GI9477@dhcp22.suse.cz> <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz> <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz> <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz> <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz> <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
 <20190815202721.GV21596@ziepe.ca>
In-Reply-To: <20190815202721.GV21596@ziepe.ca>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Thu, 15 Aug 2019 22:49:31 +0200
Message-ID: <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Michal Hocko <mhocko@kernel.org>, Feng Tang <feng.tang@intel.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Kees Cook <keescook@chromium.org>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Peter Zijlstra <peterz@infradead.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Jann Horn <jannh@google.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, 
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>, 
	Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 10:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> On Thu, Aug 15, 2019 at 10:16:43PM +0200, Daniel Vetter wrote:
> > So if someone can explain to me how that works with lockdep I can of
> > course implement it. But afaics that doesn't exist (I tried to explain
> > that somewhere else already), and I'm no really looking forward to
> > hacking also on lockdep for this little series.
>
> Hmm, kind of looks like it is done by calling preempt_disable()

Yup. That was v1, then came the suggestion that disabling preemption
is maybe not the best thing (the oom reaper could still run for a long
time comparatively, if it's cleaning out gigabytes of process memory
or what not, hence this dedicated debug infrastructure).

> Probably the debug option is CONFIG_DEBUG_PREEMPT, not lockdep?

CONFIG_DEBUG_ATOMIC_SLEEP. Like in my patch.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

