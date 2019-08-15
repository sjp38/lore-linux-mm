Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33550C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCBC621721
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:16:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="kiM9Ekjf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCBC621721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618656B0277; Thu, 15 Aug 2019 16:16:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C78D6B027A; Thu, 15 Aug 2019 16:16:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DF786B027C; Thu, 15 Aug 2019 16:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0104.hostedemail.com [216.40.44.104])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5926B0277
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:16:56 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E278952A9
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:16:55 +0000 (UTC)
X-FDA: 75825770790.16.trip97_1f597c6958662
X-HE-Tag: trip97_1f597c6958662
X-Filterd-Recvd-Size: 6223
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:16:55 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id g17so6798057otl.2
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:16:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qTHh9ZK37xd08x9Ue/sJIZ77olqIpSOlqxcia7YCCRQ=;
        b=kiM9EkjfkkvV2acXtyuHtZlSwyxVFy/luh62JpSLtwDDqFGrqqv/l8fVfIHPp21MCP
         7SmEesVoHHEi/iJMWm4H/Jl4/ZHJ7gBZkP4lp2VTsSGgM/twhyanBIFDeYKJhMAfWLUJ
         EmiJ2M3g4FY95dria69FfMx+Qm3RsWWUVpCIo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=qTHh9ZK37xd08x9Ue/sJIZ77olqIpSOlqxcia7YCCRQ=;
        b=UyaE9l7oTXs6d7RsQa6EaDcWypGGNUVvaRtPnnnZLSrYGO9cZvPHiT11PMzd7tLgeW
         clZRxwk9Im42EGsgCFILAgfoqGj6+Lo7+uWoEBI52qzRxrFdAaUC/75/01SqB2FCoIIZ
         0zq3WCrI35M1GTAp6lcv3B5jl5d/DosIj2YrhDfwGM4z4bPmJ3iXFVscM/p9I/vCwWyE
         YQ7f5Hl4U7dPxlXGAjPFxmI2QfXlwUhu3tY1RBGHKMmNTIdBEdXwbZW88TRZ9PHDg23s
         eToLpw6Vu/exM09Txn0ARC1OVGQiiZgMp2FAPmTgW0TbzmXxRhtDeqx6pWNTMSXum97p
         x+2g==
X-Gm-Message-State: APjAAAVi3mjNGdtCe4H5nJ192KFvTHQ1gSHLOAAHPVPj44y1n7x1PGKq
	pO/cL0kom07usFZTV00LjFr7nQSbYqvmcjRuiCfnaw==
X-Google-Smtp-Source: APXvYqxHW0wNM9I7rIoKCFgGR912iydB5fNuej2q7geNF6Dfxo4Lg+k3yOUXV/RnGF0DaFYbEZaKpNxIAvab1cVA2E0=
X-Received: by 2002:a9d:6955:: with SMTP id p21mr5284545oto.204.1565900214485;
 Thu, 15 Aug 2019 13:16:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190815065829.GA7444@phenom.ffwll.local> <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz> <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz> <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz> <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz> <20190815191810.GR21596@ziepe.ca> <20190815193526.GT9477@dhcp22.suse.cz>
In-Reply-To: <20190815193526.GT9477@dhcp22.suse.cz>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Thu, 15 Aug 2019 22:16:43 +0200
Message-ID: <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
To: Michal Hocko <mhocko@kernel.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Feng Tang <feng.tang@intel.com>, 
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

On Thu, Aug 15, 2019 at 9:35 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 15-08-19 16:18:10, Jason Gunthorpe wrote:
> > On Thu, Aug 15, 2019 at 09:05:25PM +0200, Michal Hocko wrote:
> >
> > > This is what you claim and I am saying that fs_reclaim is about a
> > > restricted reclaim context and it is an ugly hack. It has proven to
> > > report false positives. Maybe it can be extended to a generic reclaim.
> > > I haven't tried that. Do not aim to try it.
> >
> > Okay, great, I think this has been very helpful, at least for me,
> > thanks. I did not know fs_reclaim was so problematic, or the special
> > cases about OOM 'reclaim'.
>
> I am happy that this is more clear now.
>
> > On this patch, I have no general objection to enforcing drivers to be
> > non-blocking, I'd just like to see it done with the existing lockdep
> > can't sleep detection rather than inventing some new debugging for it.
> >
> > I understand this means the debugging requires lockdep enabled and
> > will not run in production, but I'm of the view that is OK and in line
> > with general kernel practice.
>
> Yes and I do agree with this in general.

So if someone can explain to me how that works with lockdep I can of
course implement it. But afaics that doesn't exist (I tried to explain
that somewhere else already), and I'm no really looking forward to
hacking also on lockdep for this little series.

> > The last detail is I'm still unclear what a GFP flags a blockable
> > invalidate_range_start() should use. Is GFP_KERNEL OK?
>
> I hope I will not make this muddy again ;)
> invalidate_range_start in the blockable mode can use/depend on any sleepable
> allocation allowed in the context it is called from. So in other words
> it is no different from any other function in the kernel that calls into
> allocator. As the API is missing gfp context then I hope it is not
> called from any restricted contexts (except from the oom which we have
> !blockable for).

Hm, that's new to me. I thought mmu notifiers very much can be called
from direct reclaim paths, so you have to be extremely careful with
getting back into that one. At least the lockdep splats I remember
also tend to have fs_reclaim in there, that's where all the fun comes
from.

> > Lockdep has
> > complained on that in past due to fs_reclaim - how do you know if it
> > is a false positive?
>
> I would have to see the specific lockdep splat.

I guess the lockdep annotation for invalidate_range_start carries the
same risks as the fs_reclaim annotation. Still feels like worth it.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

