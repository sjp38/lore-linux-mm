Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1656C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 18:10:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A858A21773
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 18:10:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="N6AVNHwE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A858A21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3500A6B0003; Fri, 17 May 2019 14:10:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3000E6B0005; Fri, 17 May 2019 14:10:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17A786B0006; Fri, 17 May 2019 14:10:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA3986B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 14:10:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l3so11751403edl.10
        for <linux-mm@kvack.org>; Fri, 17 May 2019 11:10:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0RAJ8dFkgMXY5OQlUUJ6T1gPWQG4AjdkRmpcqOy8B8o=;
        b=bEya0ahNtwbmwuG1GFttc5uHSTihJvSkpsA5MLDCGSnw4MzyPdRV9LzjiPSG4qPLNP
         B//Howx+ds8Gl8KqXqoLo6LqbRWG8NG+dwSkys1mKVwVOS+/iflgt2W0aWsCqQi9s4/M
         gvs1+ItDdy9KRh6iolX+sBdBm8c1NlRCO+jOtBFIYrkyAa3pZQnMt9OpGGN8er1Hcejl
         gwEwrgaVyPGqFupXuSwUFjWYPZkKTx2W0/eg6RL39NapXVnMTaOFgf3JaiE5JBP7qGBI
         bh3xPLgz93YPUsrBoTQi25EJ0bQJmo9eq/I4GB3DwhE2dxzZcCs0GNfbx/uFwSjBsH5D
         Y2rg==
X-Gm-Message-State: APjAAAX44r9aMtS6w4dOAV/HJp5ZzNeGbKg6IVoge2YWpVbwNJCwmJ5J
	KnJG0TFPpu8bzidFpkgW0vUgFRbmS81PcxdAxcX6dLHVEMrZVpUcul2DiQxGI/sfsVm2LyoZ8Vt
	BKt4MayENns3ibiltr6x3+whL+PjD+7hRlUrP6DmsVpjwxXcambDTpGxPE57d9ZVDaA==
X-Received: by 2002:a17:906:e2c2:: with SMTP id gr2mr46280152ejb.45.1558116617330;
        Fri, 17 May 2019 11:10:17 -0700 (PDT)
X-Received: by 2002:a17:906:e2c2:: with SMTP id gr2mr46280057ejb.45.1558116616143;
        Fri, 17 May 2019 11:10:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558116616; cv=none;
        d=google.com; s=arc-20160816;
        b=HVzY/kMEMcY0EejHeqSEE+xB5NN7W3dp3/k1d1Oz9vTZCzFG6gK6EVq3MZq0IXE0zW
         iwUvjsnyC4ZnO4hNhvys/Ff6HSdBjyI3nMNKi84PCaA/aGVSVJAS2m3/TaP9qEEPf4+P
         tFXC4USr4LACqzY21KBhqxz0abqjik4uMlOPjMZzwHHnkwvXKt6AjVKbItK06xv0tsy2
         9h2G5XCUx4yLDHYIMfDspPRpUKOihRwoI7waqvRBMeW9xQiprE0w8LnTxsceXwz7n8Id
         yx9AGAZbM/CKzfmgAp8vzOWCJqVOesKLdrsZQODNcHjf66uNA8+9fiQ1us/EPhDrtBwy
         Bmbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0RAJ8dFkgMXY5OQlUUJ6T1gPWQG4AjdkRmpcqOy8B8o=;
        b=jUdT5Ej6QWPvBQYpL+xGGFkzlyJbDwv3YiBPpl+ttuMnVT7L5ZujJuzRBzUNMDytAR
         1rhrzQofKAjEo7/qCTeRfd5NnNC7XB/rmwsIUzdzhLyfvz8l3HUpJgC7SxnYsU7higXe
         RIitFpBOAtxSiIv1wgSiz6Ggr0jswUOCEd/OQPCw4G6AH1chPRwFdGkj7YL9JP8LWrdh
         chQ/iEEAoEGjnAJbXmr93f4LG3wopG+UKIoY4qgqor4hzNH8kNcAx3ExM2vyHqyDkwgn
         BfQ5knKqrGJtstQAm5U6d1kluSy58iRMLB/wWa/1cLDVVXuA+8Ir9l9NxFEgZOsfTIBM
         D+0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=N6AVNHwE;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b51sor1239503ede.8.2019.05.17.11.10.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 11:10:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=N6AVNHwE;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0RAJ8dFkgMXY5OQlUUJ6T1gPWQG4AjdkRmpcqOy8B8o=;
        b=N6AVNHwED44tjfNeBflxf/4LK+NXnqWsv17JWf6m0n56Z8TxPCSc5PmhLfxKM9WFrq
         YbKovej0m6JAq0uY+V0fukul3/8snNc7VVGW3uaJCYOv9kESzesDs34u+v4WAStgHP3c
         sBeltk1m46EU7g2kMwLBL1Xlc9O9R/OxZjl/+/qkgn3IyGRlBAhWR9BgYqAdPvWtybzJ
         IgFGR1LpSroJPjuo0A0Qc1QBzB29kPQIib6uBuK0f/3Wx8viB4rvGm7IMOZPK6bLo+in
         ON8O8uP2Me8M1QHTOgHYyJqE46rojKl0mOXRMk3JP5y+xtGruIDjYea+Vte5dqNdk7pj
         Jbjg==
X-Google-Smtp-Source: APXvYqy265H8YTRxW0fmCC2I6ZxM8EIDTEHONdgksak2H40jR89a0QYHQFohoS/iSUfnFLtzqxC5+RMenGd+voNYkNc=
X-Received: by 2002:a50:ee01:: with SMTP id g1mr58841265eds.263.1558116615828;
 Fri, 17 May 2019 11:10:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
 <20190502184337.20538-3-pasha.tatashin@soleen.com> <cac721ed-c404-19d1-71d1-37c66df9b2a8@intel.com>
 <CAPcyv4greisKBSorzQWebcVOf2AqUH6DwbvNKMW0MQ5bCwYZrw@mail.gmail.com>
In-Reply-To: <CAPcyv4greisKBSorzQWebcVOf2AqUH6DwbvNKMW0MQ5bCwYZrw@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 17 May 2019 14:10:04 -0400
Message-ID: <CA+CK2bAeLJFRDTNnUrz_JCP5DVqM2N8+09q1TX7+OCE7b5v+1A@mail.gmail.com>
Subject: Re: [v5 2/3] mm/hotplug: make remove_memory() interface useable
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, James Morris <jmorris@namei.org>, 
	Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dan,

Thank you very much for your review, my comments below:

On Mon, May 6, 2019 at 2:01 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Mon, May 6, 2019 at 10:57 AM Dave Hansen <dave.hansen@intel.com> wrote:
> >
> > > -static inline void remove_memory(int nid, u64 start, u64 size) {}
> > > +static inline bool remove_memory(int nid, u64 start, u64 size)
> > > +{
> > > +     return -EBUSY;
> > > +}
> >
> > This seems like an appropriate place for a WARN_ONCE(), if someone
> > manages to call remove_memory() with hotplug disabled.

I decided not to do WARN_ONCE(), in all likelihood compiler will
simply optimize this function out, but with WARN_ONCE() some traces of
it will remain.

> >
> > BTW, I looked and can't think of a better errno, but -EBUSY probably
> > isn't the best error code, right?

-EBUSY is the only error that is returned in case of error by real
remove_memory(), so I think it is OK to keep it here.

> >
> > > -void remove_memory(int nid, u64 start, u64 size)
> > > +/**
> > > + * remove_memory
> > > + * @nid: the node ID
> > > + * @start: physical address of the region to remove
> > > + * @size: size of the region to remove
> > > + *
> > > + * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
> > > + * and online/offline operations before this call, as required by
> > > + * try_offline_node().
> > > + */
> > > +void __remove_memory(int nid, u64 start, u64 size)
> > >  {
> > > +
> > > +     /*
> > > +      * trigger BUG() is some memory is not offlined prior to calling this
> > > +      * function
> > > +      */
> > > +     if (try_remove_memory(nid, start, size))
> > > +             BUG();
> > > +}
> >
> > Could we call this remove_offline_memory()?  That way, it makes _some_
> > sense why we would BUG() if the memory isn't offline.

It is this particular code path, the second one: remove_memory(),
actually tries to remove memory and returns failure if it can't. So, I
think the current name is OK.

>
> Please WARN() instead of BUG() because failing to remove memory should
> not be system fatal.

As mentioned earlier, I will keep BUG(), because existing code does
that, and there is no good handling of this code to return on error.

Thank you,
Pavel

