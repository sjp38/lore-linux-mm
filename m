Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12B96C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:57:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B80E120675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:57:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="DpxZGAGZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B80E120675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F8748E0020; Wed,  6 Mar 2019 10:57:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A7548E0015; Wed,  6 Mar 2019 10:57:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 295FB8E0020; Wed,  6 Mar 2019 10:57:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9D258E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:57:43 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id b10so5383323oti.21
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:57:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=12aSmT+/lR/NKB5S9pyJmInfMczgWXtoG0X5j52F2FA=;
        b=TrPktqxs9d7BWFmCg7NDul5s/1R70busyEoo1AJ+U6uDEEhyUP70SMJtNl8D4f364K
         H4wfdD/WscX3DFn1Zx7IP5/pB5pofA/798LZWd65cDohJA2KEOZgJVJTQ3X4YDlwbJNv
         u1bFYBOXsg3kKKYg0j+B/sR9OSwgN4PrbANEnwyApOnX+YPQuDrVexh+ij5m9qlec7VE
         QwpGJOyByqSRXZ4th17yci+LZ7VUt4iRPF54HfpAVEMhg/SujWzdPHH7mItGufVQtxE0
         psd3rDopEeNvyD9VtJ75jKGAWoBcrKR5XeZy4LFIJjRg47Xza0CKSZJAxuZsnTqFzgGC
         5MwA==
X-Gm-Message-State: APjAAAV4/+bATMvceyCVZfOC1CzSNBH0xWiMNNmanCNpjIom7o76d6gw
	SJ08xSfSgwMKzAV1eeUN58r2vyM2XJUPzd2jMhXPLMbERKeUcvllfILxd8hTGKgKlz2ZgKi69Rb
	dot33Gr9KvIDr8Q2JlvjDpd7UNqc66A+N2CHPLVao+GuG+ZJhdsrpJjDkDDo+CSH0R36+EoWBMS
	5T7dze9YznkAf2RKH6yFUg20sAcQWso/mHHRfmHIYp7OFCmJgLFCXgK0rft31GwCv9SE8UgE+UV
	mzKZ+Jj3B4GcQr/Hj0qXP1PIZnqxDT2YqJ9ISST4JDncwqaVkQ591V+y+NIj6srwMLDXNDZFKY7
	YQvGU1pbrouTfX4kfPgsxVu8T3kjHOEdEWIvWtaEzoqFBq9pWEzd0xh0ICUBHd82bTBjYim8AIU
	Y
X-Received: by 2002:a9d:76c5:: with SMTP id p5mr2617518otl.283.1551887863477;
        Wed, 06 Mar 2019 07:57:43 -0800 (PST)
X-Received: by 2002:a9d:76c5:: with SMTP id p5mr2617477otl.283.1551887862631;
        Wed, 06 Mar 2019 07:57:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887862; cv=none;
        d=google.com; s=arc-20160816;
        b=VC2ALs25KR/GXDHsX5GLYmvocgWrYccHCw75byY5PoMwq4GoWrgr/ci1swoAXuH9Du
         Lh9UJsSMRIUqvc+lYKEHz/JfIAkyRVUjszElxPWT7loM4qC4AwJl+5ltyNTRREkgaDgw
         /gMCHwKQ9YsoimvqW5jrj2B7RJUumu814vuz+IctELB6Rp5aDYwABgru7x7wlxuoEMSJ
         a09GhiW0A0AzNMIbjmMakcpDhslDLL0nrS+6I0y7sabl0VhEXQthG3V07NHGHVeyyk4r
         7IOz9yjFUa/eonD/4IKPPtUEo26Pger+F1MrHDruX0dyuAnQbyuXY5LVz51dsRxChDL5
         jM/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=12aSmT+/lR/NKB5S9pyJmInfMczgWXtoG0X5j52F2FA=;
        b=d3awPXiOTTzm5N3z6rGgGQfjTviNuKk6QHiyilbrbNXjsyM7MpZ18LDPOW9kiX/D5I
         vhHe3PU5lp4JjzcKq8HbgrtKGNs3f9gbE0yWEhCFnIVGEvzk6tV9T810xOoJ23DGCmOt
         ieOZqf513xHRBRwev9eP94ZbEsLiPBoTCgMP5BBcDjem/TfarGT+m7lVOWelmNlbwcxb
         TSWJfpqxO9ud9k+1gHe7n2D6BloNARHhgOPQq2Oe6OfjzTurSc0ol11Z+UTE6tT537Es
         0A6HwNkEf7sRF204Atx+yxBRzZVBX5FCKPUOLodHDqxUmbA3mxo4ME5e/JlACTS/swqX
         iWNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=DpxZGAGZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13sor1076823otn.97.2019.03.06.07.57.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 07:57:42 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=DpxZGAGZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=12aSmT+/lR/NKB5S9pyJmInfMczgWXtoG0X5j52F2FA=;
        b=DpxZGAGZBbtSRaU8yNyR/UJx6v0B6VF0wbwKQXom3BSBwFwORw4Y3lwi0wBMP/JMe2
         pGvKBDjpy8pjFT4ngLe02Pjt6xjFj3xPmYx7PwHsbO15wu3dkdDkeijdm7lnRA3bzTTh
         MFlPzfS2C9FcJLevidZTKPoZdfyuLkemQ5jzytrJnsqz22wvD9+g3SbKEIVejHE79tHs
         0q7d3EYiXhxOLLJRU19C4/HXoy/qTzq5SU6Df/GtveDoeSD/D2ED43GFkmmfpNquwPpX
         ltSMyJp1kNvleGXZ/UguDIzllcig24OTNV9N3VhD27CCuUZ80n2kUe5idEbX9Jckwr2S
         M5Hg==
X-Google-Smtp-Source: APXvYqyUK8bFOXOkwmQyq5HlPa9dyaManelpH63WsqJmzxRH2vRpGlCqwOef9mTyxEDLlq+0NuZ+l6SwEIBonJdW/W4=
X-Received: by 2002:a9d:77d1:: with SMTP id w17mr4679585otl.353.1551887861656;
 Wed, 06 Mar 2019 07:57:41 -0800 (PST)
MIME-Version: 1.0
References: <20190129212150.GP3176@redhat.com> <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com> <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com> <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com> <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com> <20190306155126.GB3230@redhat.com>
In-Reply-To: <20190306155126.GB3230@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Mar 2019 07:57:30 -0800
Message-ID: <CAPcyv4iB+7LF-ZOF1VXE+g2hS7Gb=+RbGAmTiGWDsaikEuXGYw@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 7:51 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Mar 05, 2019 at 08:20:10PM -0800, Dan Williams wrote:
> > On Tue, Mar 5, 2019 at 2:16 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > On Wed, 30 Jan 2019 21:44:46 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > > >
> > > > > > Another way to help allay these worries is commit to no new exports
> > > > > > without in-tree users. In general, that should go without saying for
> > > > > > any core changes for new or future hardware.
> > > > >
> > > > > I always intend to have an upstream user the issue is that the device
> > > > > driver tree and the mm tree move a different pace and there is always
> > > > > a chicken and egg problem. I do not think Andrew wants to have to
> > > > > merge driver patches through its tree, nor Linus want to have to merge
> > > > > drivers and mm trees in specific order. So it is easier to introduce
> > > > > mm change in one release and driver change in the next. This is what
> > > > > i am doing with ODP. Adding things necessary in 5.1 and working with
> > > > > Mellanox to have the ODP HMM patch fully tested and ready to go in
> > > > > 5.2 (the patch is available today and Mellanox have begin testing it
> > > > > AFAIK). So this is the guideline i will be following. Post mm bits
> > > > > with driver patches, push to merge mm bits one release and have the
> > > > > driver bits in the next. I do hope this sound fine to everyone.
> > > >
> > > > The track record to date has not been "merge HMM patch in one release
> > > > and merge the driver updates the next". If that is the plan going
> > > > forward that's great, and I do appreciate that this set came with
> > > > driver changes, and maintain hope the existing exports don't go
> > > > user-less for too much longer.
> > >
> > > Decision time.  Jerome, how are things looking for getting these driver
> > > changes merged in the next cycle?
> > >
> > > Dan, what's your overall take on this series for a 5.1-rc1 merge?
> >
> > My hesitation would be drastically reduced if there was a plan to
> > avoid dangling unconsumed symbols and functionality. Specifically one
> > or more of the following suggestions:
> >
> > * EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
> > surface for out-of-tree consumers to come grumble at us when we
> > continue to refactor the kernel as we are wont to do.
> >
> > * A commitment to consume newly exported symbols in the same merge
> > window, or the following merge window. When that goal is missed revert
> > the functionality until such time that it can be consumed, or
> > otherwise abandoned.
> >
> > * No new symbol exports and functionality while existing symbols go unconsumed.
> >
> > These are the minimum requirements I would expect my work, or any
> > core-mm work for that matter, to be held to, I see no reason why HMM
> > could not meet the same.
>
> nouveau use all of this and other driver patchset have been posted to
> also use this API.
>
> > On this specific patch I would ask that the changelog incorporate the
> > motivation that was teased out of our follow-on discussion, not "There
> > is no reason not to support that case." which isn't a justification.
>
> mlx5 wants to use HMM without DAX support it would regress mlx5. Other
> driver like nouveau also want to access DAX filesystem. So yes there is
> no reason not to support DAX filesystem. Why do you not want DAX with
> mirroring ? You want to cripple HMM ? Why ?

There is a misunderstanding... my request for this patch was to update
the changelog to describe the merits of DAX mirroring to replace the
"There is no reason not to support that case." Otherwise someone
reading this changelog in a year will wonder what the motivation was.

