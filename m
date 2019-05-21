Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DB20C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:00:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C26FC21019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:00:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="iWPYjGwy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C26FC21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71CF16B0006; Tue, 21 May 2019 12:00:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F4766B0007; Tue, 21 May 2019 12:00:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BCBA6B0008; Tue, 21 May 2019 12:00:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3197D6B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:00:50 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id w5so6240447oig.18
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:00:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NhMdeTlwpp1ipABlk4vrZFRm+ansgm/gZL6cQawSF+c=;
        b=c2eszqlen7d7Cboc5U3wPYR+merqCjwj7BdK+8mQytiiJ7F6I1m5dP3yIxyXSCwXh8
         czd2e76AW7jRUm+PgWTVqfCP+X1MLWO8fAqMHBxLQtr87fWF/m1D1COKz6mx0PyjsIwZ
         7nuybGa8CKHm8azgwoc6noLt9tPKDTSVRFD9jpiaIuE35WPPD33e11/emNmHmNYiTZRP
         29ZW6VkTX5Ep6hXIKs3CyM09otrQqhWEzmYZP9+C2FHm8zQdebvlF3Ids2rLelBRpLUJ
         Co8XZoeyRH37lVMPziauSplSooP9THH9VmUvlfdEOMQ7trTo3URvu0YORYmn+plT8F+S
         GGGg==
X-Gm-Message-State: APjAAAWI0+wm2b87+fogR7Ftm0/orOSZLNdgXsP46IUN5IK1+jNu70AJ
	UlDcgd2QvLpEKDzi/cRQYsiJLG13/EJSrvyXXJknIGZ0vmgRfdj7LaF+urUUyMd+jev2ZPXHi8i
	rjL/e/EW89rm/uOI2nH/mGG0vw61YKT9S4IqsYLRx3waVzqhucN+lEc0zarNZWwkIlA==
X-Received: by 2002:aca:4a97:: with SMTP id x145mr2113049oia.161.1558454449797;
        Tue, 21 May 2019 09:00:49 -0700 (PDT)
X-Received: by 2002:aca:4a97:: with SMTP id x145mr2112957oia.161.1558454448790;
        Tue, 21 May 2019 09:00:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558454448; cv=none;
        d=google.com; s=arc-20160816;
        b=xTYA6QrwkhS//ar2XE58L7fuQE5EZ48phrhLCAn2uVlFXYubS6cpCVaHbq/+UtqjdF
         n4pXr2RqfSxBpWIvYHotjjmIzWr72qQo1jmOt4ZUu/KCAwDiN7c1uolk8qJ3ti0oVKQz
         KYJRW+w/v1gTEvQf2qlnqonnWHs7pdyfjFz+2U8xXT4Eif498SgRETQJH+YHy674YhN2
         jzirZly8j1z7LLEFoS9QwJwyfXc3/1SvJpmu/SF8QLqJvGEc8/+X98uList1lh9aodZZ
         mzaDcNAW74j0tWGNNSv81yHTXDrajYXiANheP8f1jgkRQzkfuw0dr1hsTpLF93k4+OJ/
         99TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NhMdeTlwpp1ipABlk4vrZFRm+ansgm/gZL6cQawSF+c=;
        b=mwWlvzmHSKUsrHD8M8cUnxTtoI9+SMRC/A3VqlniitIAdE1yn/bN6azjw+fU/x5FpS
         QQ8XtVqPfnYJetWxlicWFn4kTcPmCuEfId05YHZ6LofhslfjWZHEsOJJbkRuivRQoAXk
         cKNWHLtlSSYX1rPstl8O8VdbVjWVtbfUegCrQflJk9YpOhtdFu0/L2XTSe9n8Cvt/KJb
         0Ae5bM9xfoyDMxHVl+WSXSwweAw6gwBXZ3bH8uKvG82kGy5DeSr2XGG4XBCpp7o3tRrT
         Lx1mPymsmK+tiavCAijYU/KQTckksRNjxZDLyjljHXfXXRwtz9vYRZ0nHkKWmkZjeMVD
         TOdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=iWPYjGwy;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t195sor8413544oih.161.2019.05.21.09.00.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 09:00:48 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=iWPYjGwy;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NhMdeTlwpp1ipABlk4vrZFRm+ansgm/gZL6cQawSF+c=;
        b=iWPYjGwyHiS4RY9vwsXeZ8i6fKnHYt4FFltlGbL8zLBXNA8i8brUrULMsuEhL8dHVf
         mFcmOyqSuXprZfVNumy/KKsfMmPjtpula612aIpH4kUKtfFSu1IVVl9/lN7lo1EbO5Di
         Nm953Hx97nGZEsz7iDskJM7qE79xpAl3pv/ys=
X-Google-Smtp-Source: APXvYqz1HRnyxysQSyfGmkEPM6kIYzznd5oq6OhQwPIPC1dkDjzOHTKgjff5dHGhujv1bAcBk2AFzcykzlU6H9OZNBk=
X-Received: by 2002:aca:e4c8:: with SMTP id b191mr4039039oih.110.1558454448157;
 Tue, 21 May 2019 09:00:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190520213945.17046-4-daniel.vetter@ffwll.ch> <20190521154059.GC3836@redhat.com>
In-Reply-To: <20190521154059.GC3836@redhat.com>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Tue, 21 May 2019 18:00:36 +0200
Message-ID: <CAKMK7uEaKJiT__=dt=ROUP4Kkq1NgwScLJFQcMuBs2GYjMWOLw@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm, notifier: Add a lockdep map for invalidate_range_start
To: Jerome Glisse <jglisse@redhat.com>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, Chris Wilson <chris@chris-wilson.co.uk>, 
	Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	Michal Hocko <mhocko@suse.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 5:41 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Mon, May 20, 2019 at 11:39:45PM +0200, Daniel Vetter wrote:
> > This is a similar idea to the fs_reclaim fake lockdep lock. It's
> > fairly easy to provoke a specific notifier to be run on a specific
> > range: Just prep it, and then munmap() it.
> >
> > A bit harder, but still doable, is to provoke the mmu notifiers for
> > all the various callchains that might lead to them. But both at the
> > same time is really hard to reliable hit, especially when you want to
> > exercise paths like direct reclaim or compaction, where it's not
> > easy to control what exactly will be unmapped.
> >
> > By introducing a lockdep map to tie them all together we allow lockdep
> > to see a lot more dependencies, without having to actually hit them
> > in a single challchain while testing.
> >
> > Aside: Since I typed this to test i915 mmu notifiers I've only rolled
> > this out for the invaliate_range_start callback. If there's
> > interest, we should probably roll this out to all of them. But my
> > undestanding of core mm is seriously lacking, and I'm not clear on
> > whether we need a lockdep map for each callback, or whether some can
> > be shared.
>
> I need to read more on lockdep but it is legal to have mmu notifier
> invalidation within each other. For instance when you munmap you
> might split a huge pmd and it will trigger a second invalidate range
> while the munmap one is not done yet. Would that trigger the lockdep
> here ?

Depends how it's nesting. I'm wrapping the annotation only just around
the individual mmu notifier callback, so if the nesting is just
- munmap starts
- invalidate_range_start #1
- we noticed that there's a huge pmd we need to split
- invalidate_range_start #2
- invalidate_reange_end #2
- invalidate_range_end #1
- munmap is done

But if otoh it's ok to trigger the 2nd invalidate range from within an
mmu_notifier->invalidate_range_start callback, then lockdep will be
pissed about that.

> Worst case i can think of is 2 invalidate_range_start chain one after
> the other. I don't think you can triggers a 3 levels nesting but maybe.

Lockdep has special nesting annotations. I think it'd be more an issue
of getting those funneled through the entire call chain, assuming we
really need that.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

