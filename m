Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D3FC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 07:08:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79E0A20882
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 07:08:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aswEem68"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79E0A20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBCF98E0003; Tue, 30 Jul 2019 03:08:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6C8F8E0002; Tue, 30 Jul 2019 03:08:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0E298E0003; Tue, 30 Jul 2019 03:08:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 773D08E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 03:08:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t18so29989944pgu.20
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 00:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=hQ/nGVg08UlzjZmMjcg4DzO30BY3YCIyVYTPkdiYhV8=;
        b=LvVam2mLCiscMb7Q29spSUamw52Syt5bGQTMlutQH6Bpfh6NENl1Yg98Em/EwYSxyY
         60jq7l28wxeCdC3txBx4v1quHmrUiytaVpNVT6Hnxd25tDXt550lmimgNoHrB8dV86ge
         025Jog/VQRLv5uLqfQ4mdXan9EjTrOjnCwqeOfBPJ1myunCetKS5HC9kr/Xd7V3kNEMW
         68NG6RlgFLOe3eudhwyTca/OiDP6ojhiTufMZdGaugyJm1/kG8XWLNyl4RGs/2QSAbt0
         6H0ua0+VgKNLrDdF6oy9Vpyy6KKgpVSuME4+8FQ4L6dzZGis7Go9VwgPIkZh7jblZEdK
         RiKQ==
X-Gm-Message-State: APjAAAWTC/ewEY1XZXrME+R3aQ0IE8MJVxuTTAjPiEJHQ4FZHTZaHgua
	kZY0CGspX2Vnm/t7SV8L8Q8YbOVXZihF3PU+rj/DV5xXqVMGziIVEKJ/jMEjX8OxwYsw426emlk
	X8xAOOGTCiAkagPqiBXRdgTz4hDJ9E8NxOaCbsUSMnOIRdxPJensS3yiIZ7FNUu4atg==
X-Received: by 2002:a63:1f1f:: with SMTP id f31mr106451102pgf.353.1564470503952;
        Tue, 30 Jul 2019 00:08:23 -0700 (PDT)
X-Received: by 2002:a63:1f1f:: with SMTP id f31mr106451050pgf.353.1564470502951;
        Tue, 30 Jul 2019 00:08:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564470502; cv=none;
        d=google.com; s=arc-20160816;
        b=I23hGODIVYGHkubAv3R+wAzdL1rDlnmwIIhm93whWRT6S280R/Vv0BYZU2jBZq0WDo
         Jv0Gq4y+b0imXy4ZKByzoPz8nZ98T+r5BjoTieAjkcLxje+E07mI80l5KXqRrSx2Bcfw
         4jVzCA8ShCB7yBPbhpb4KpFyf/UP4grPLcLevcBqItsc6amNiwXEIlhR4oECbgvdPumY
         0NZrlPH+fODIzKDAurlLmz9amV5k9kEdvi8o92nvKGLeEP8ZN98bFp0FcxN1RXDArY8X
         vdmmbHOcL3g76+/SOn1VEHVBBHI1wGw/N85qBod9PAFwbziLxHYnWad4wRwm64O398Yc
         2azw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=hQ/nGVg08UlzjZmMjcg4DzO30BY3YCIyVYTPkdiYhV8=;
        b=Xv8NJC75XbLUrIhb5oSJN/Rdm9wEyXxXCN1nZrjO58TsnJsnsEqqEIQsYyZmB14Af8
         58/xoah584eZhD0UyTgS3xLxpkFiZAnKZjdVkDCEudKVb9X16qUWpQQX01JCWYSmK0zc
         U+TBiEkaMRkOW3L8HJyG3MnXkbJq6X4lmFvZBlBFJ82xw/XHhs8r/hR41EUY8pu/Yu4h
         ITZHKVfTaXazC19QOtaqSW3X727u+0PeU0QEswVGZjMPZBkTLLTzHl1iWnlEahktPEb8
         NyPiwp0yzG7T0Gg6wYYtAQDLEavf/tHOc9mHa7Vm6xMb173HUGM8220aHtURu8PBdo1i
         tI6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aswEem68;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor76095048pll.35.2019.07.30.00.08.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 00:08:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aswEem68;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=hQ/nGVg08UlzjZmMjcg4DzO30BY3YCIyVYTPkdiYhV8=;
        b=aswEem68vIJpVv8I7Vodird6t8Ly3CsDS5y2jYafJE2w4hUqjTVH7ftkdy1kU5ohdo
         uId+/5lFBGfit53zKkA/WlqNbAtOioouT3tPQ7N3Enq8JBvTv7uPkZ8fMwx18aT/sCfT
         z+wpwUOcZfqlxy+Xgj3lZnkNwI88SLAJ6sHxco0twLsja1rmPftlj1MGDzmxM//51Hhk
         Dz/EBn2pNWDJsn0AgxaZZpRi9JUn/XYuFGCwQFWh4HBCLS7DKk3g3h1LiGFOeSnnUds0
         jn3xea7vNxNHiGZ8l7HUFQf1+7JfgJOjP3vsmxbHUEKPB4LnQP+hJjrZiyzM2WWm0lgk
         q/lA==
X-Google-Smtp-Source: APXvYqzqtL2OYzfHNLoigrtAQfqQ3FO3Tc5ED3jBXVYqElY6ZnboiVlVBnjT1kgB7V6Zqk62L977Cg==
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr113629900pls.107.1564470502639;
        Tue, 30 Jul 2019 00:08:22 -0700 (PDT)
Received: from rashmica.ozlabs.ibm.com ([122.99.82.10])
        by smtp.googlemail.com with ESMTPSA id x128sm100977705pfd.17.2019.07.30.00.08.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 00:08:21 -0700 (PDT)
Message-ID: <6d3e860ba83bd7677cfba36f707874cc8fd8bf2b.camel@gmail.com>
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
From: Rashmica Gupta <rashmica.g@gmail.com>
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, 
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com, 
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Tue, 30 Jul 2019 17:08:15 +1000
In-Reply-To: <b3fd1177-45ef-fd9e-78c8-d05138c647da@redhat.com>
References: <20190625075227.15193-1-osalvador@suse.de>
	 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
	 <20190626080249.GA30863@linux>
	 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
	 <20190626081516.GC30863@linux>
	 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
	 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
	 <0cd2c142-66ba-5b6d-bc9d-fe68c1c65c77@redhat.com>
	 <b7de7d9d84e9dd47358a254d36f6a24dd48da963.camel@gmail.com>
	 <b3fd1177-45ef-fd9e-78c8-d05138c647da@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-07-29 at 10:06 +0200, David Hildenbrand wrote:
> > > Of course, other interfaces might make sense.
> > > 
> > > You can then start using these memory blocks and hinder them from
> > > getting onlined (as a safety net) via memory notifiers.
> > > 
> > > That would at least avoid you having to call
> > > add_memory/remove_memory/offline_pages/device_online/modifying
> > > memblock
> > > states manually.
> > 
> > I see what you're saying and that definitely sounds safer.
> > 
> > We would still need to call remove_memory and add_memory from
> > memtrace
> > as
> > just offlining memory doesn't remove it from the linear page tables
> > (if 
> > it's still in the page tables then hardware can prefetch it and if
> > hardware tracing is using it then the box checkstops).
> 
> That prefetching part is interesting (and nasty as well). If we could
> at
> least get rid of the manual onlining/offlining, I would be able to
> sleep
> better at night ;) One step at a time.
>

Ok, I'll get to that soon :)

> > > (binding the memory block devices to a driver would be nicer, but
> > > the
> > > infrastructure is not really there yet - we have no such drivers
> > > in
> > > place yet)
> > > 
> > > > I don't know the mm code nor how the notifiers work very well
> > > > so I
> > > > can't quite see how the above would work. I'm assuming memtrace
> > > > would
> > > > register a hotplug notifier and when memory is offlined from
> > > > userspace,
> > > > the callback func in memtrace would be called if the priority
> > > > was
> > > > high
> > > > enough? But how do we know that the memory being offlined is
> > > > intended
> > > > for usto touch? Is there a way to offline memory from userspace
> > > > not
> > > > using sysfs or have I missed something in the sysfs interface?
> > > 
> > > The notifier would really only be used to hinder onlining as a
> > > safety
> > > net. User space prepares (offlines) the memory blocks and then
> > > tells
> > > the
> > > drivers which memory blocks to use.
> > > 
> > > > On a second read, perhaps you are assuming that memtrace is
> > > > used
> > > > after
> > > > adding new memory at runtime? If so, that is not the case. If
> > > > not,
> > > > then
> > > > would you be able to clarify what I'm not seeing?
> > > 
> > > The main problem I see is that you are calling
> > > add_memory/remove_memory() on memory your device driver doesn't
> > > own.
> > > It
> > > could reside on a DIMM if I am not mistaking (or later on
> > > paravirtualized memory devices like virtio-mem if I ever get to
> > > implement them ;) ).
> > 
> > This is just for baremetal/powernv so shouldn't affect virtual
> > memory
> > devices.
> 
> Good to now.
> 
> > > How is it guaranteed that the memory you are allocating does not
> > > reside
> > > on a DIMM for example added via add_memory() by the ACPI driver?
> > 
> > Good point. We don't have ACPI on powernv but currently this would
> > try
> > to remove memory from any online memory node, not just the ones
> > that
> > are backed by RAM. oops.
> 
> Okay, so essentially no memory hotplug/unplug along with memtrace.
> (can
> we document that somewhere?). I think
> add_memory()/try_remove_memory()
> could be tolerable in these environments (as it's only boot memory).
>
Sure thing.


