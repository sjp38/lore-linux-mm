Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8BF7C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 18:01:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF31E20675
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 18:01:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Gesm1Mat"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF31E20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 492FA6B026C; Mon,  6 May 2019 14:01:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41C406B026D; Mon,  6 May 2019 14:01:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E4736B026E; Mon,  6 May 2019 14:01:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 011D16B026C
	for <linux-mm@kvack.org>; Mon,  6 May 2019 14:01:27 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id q82so4657286oif.7
        for <linux-mm@kvack.org>; Mon, 06 May 2019 11:01:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=s1iYiXewvQHx5myE/g1Y4h4JHD9obTw48tmYZs0bXqI=;
        b=nGZK4QRZsKkIvE28t5sO0PToPv601qQNo/FJ26SJc27m20SmflBCSVYxQzfqH1bqxc
         iZHeGqIpudk2YftuK7Bz2CCu4laWw1Ze63ndEQzw3tyncnqlXnBvWjsr1QWMOwbIYn5h
         4wX+RWZjg8a8jLr8lJoPXlRnbGrH/QQFnV8ZBw/YBT73eDbn+DMsWbHOLPsKdMfTFYuT
         wi7i4S/4zEJxOoDu/AmO2hmTQdmz6tOvdji0PMMBGl4v8NoST76C7EKCzRBJ0pQgphY2
         k5w1jWd77deSjZV0uxXWkKSnKKio/clo7Px2ZrhSLUn/PYJMISDWAUeb23cMPqV1EBKL
         HXMQ==
X-Gm-Message-State: APjAAAVjcc/WqC0GEUvzsFbdRKUQwJ8XSB+63/rkZ3mMCf3M21pJ8LxD
	+AzJQZegoGsIjoAgTswYx+riZraVle6cAr3xzmntYll3RJbx05un26Ln2GeasVVbq5k/co6863z
	rBeLTeUN0QTL6GADrJUYlT/NQnNX6SqDn/C4IMhhP3MdAtV7HNgtrCHzKNHF4lYHc+Q==
X-Received: by 2002:aca:3c8a:: with SMTP id j132mr1862990oia.38.1557165686592;
        Mon, 06 May 2019 11:01:26 -0700 (PDT)
X-Received: by 2002:aca:3c8a:: with SMTP id j132mr1862962oia.38.1557165685914;
        Mon, 06 May 2019 11:01:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557165685; cv=none;
        d=google.com; s=arc-20160816;
        b=zADWvECIltnJNSZD7PBdk8MZnaBcq4rND2mX+dg0OHomp3riAsD/Va24HKzcjFiZwX
         LrUvIsyqWaxMhaCmJKhus9zgpFCwTwpBFaFkZtkLFs+G3nd8D1LR9DIXm73y4xaTh1fI
         lcuWh+qFyZQwc7b2hQakpyx84zX7Sv9S8aCpoIXFqg49YAbmPH1RJVSOYTNm8XZ8TzXV
         wBbIqXE/jYAAfLR/smV8E/sBzNjhyMGDzHqpnRheQ3KO2S2qsn12KRk0xWVaKtL463G2
         b46oczn+cXgqmkV+D8OkZrZ1hzYJwcqHDT1ZtbqwND8+H/czi9Y+GQa9KcxW8lsl5R8b
         /CEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=s1iYiXewvQHx5myE/g1Y4h4JHD9obTw48tmYZs0bXqI=;
        b=KMTMMvydCqMu0w0Vpr0dmbN4UUk1ORWSZymsXtdDA7gBe9VJ5qp+CJPfAyElSR9zjp
         gGUFAU+c3mNYOj5q/v1YiDi+t12aV5Bdbhlal3+mXmTC9cd04VkF/SF7EPygQ04NMnAH
         W1nXcsYsL4RwOyEeEbhXEn+pnoryoRnzsYIxRJkMN/BJJsmFo/mm8LfM16fYSpAX7nlD
         GzS8aUtWQ74pPZ2z9AYk9i4sZoqRcqYQQ1zQA76Z/quOYkxts8nGLnjlyliQ51HVaVw5
         07jgCUPYoxlK/KrZknYAEr7UzxjuPK9EITSWfGpopMOvCJtiIU/qgW00o2JFZJgZsmUY
         CCpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Gesm1Mat;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p23sor5017795otl.10.2019.05.06.11.01.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 11:01:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Gesm1Mat;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s1iYiXewvQHx5myE/g1Y4h4JHD9obTw48tmYZs0bXqI=;
        b=Gesm1Mat5Nvdr9Z6ppAbheRkkXki5hmEJfki+aAZEgQWtXeZOTMMrgHdcrUMVJlQDM
         EoFBqW0epQyBVW0aMfUQWMZnSCnDG8Y/vtE5zcyaAH6Zdl9pu/EraJnHe6FBYcMXyLyp
         VZWggnrv7fI/MHQOhvLueK8w7k5e1LgXjHwFDufU47j2WbehxdNld3it11T/RfmzXJrP
         ljgYCI7GsW9S1KDe1lCVZ4mK3cyWa3kT8S9i8NiXyvnLEBSmbjhWarFP7+6KuIOEkME3
         7O9VFfUN9zNq29/cUxKNj4nEuJwTTMN48lYv1nIyegLPGtL2vWXAzQYZsJ+V1TQeTBnW
         0sdA==
X-Google-Smtp-Source: APXvYqyX9nJzOdD3XQZPHP+tb9t4162dRKXqMf2zXk6saJvTjLay55UFP+hEuwJnc0ji6oilX5u1sKGnO6ke6FVIfL4=
X-Received: by 2002:a9d:7ad1:: with SMTP id m17mr17304018otn.367.1557165685323;
 Mon, 06 May 2019 11:01:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
 <20190502184337.20538-3-pasha.tatashin@soleen.com> <cac721ed-c404-19d1-71d1-37c66df9b2a8@intel.com>
In-Reply-To: <cac721ed-c404-19d1-71d1-37c66df9b2a8@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 6 May 2019 11:01:14 -0700
Message-ID: <CAPcyv4greisKBSorzQWebcVOf2AqUH6DwbvNKMW0MQ5bCwYZrw@mail.gmail.com>
Subject: Re: [v5 2/3] mm/hotplug: make remove_memory() interface useable
To: Dave Hansen <dave.hansen@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>, James Morris <jmorris@namei.org>, 
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

On Mon, May 6, 2019 at 10:57 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> > -static inline void remove_memory(int nid, u64 start, u64 size) {}
> > +static inline bool remove_memory(int nid, u64 start, u64 size)
> > +{
> > +     return -EBUSY;
> > +}
>
> This seems like an appropriate place for a WARN_ONCE(), if someone
> manages to call remove_memory() with hotplug disabled.
>
> BTW, I looked and can't think of a better errno, but -EBUSY probably
> isn't the best error code, right?
>
> > -void remove_memory(int nid, u64 start, u64 size)
> > +/**
> > + * remove_memory
> > + * @nid: the node ID
> > + * @start: physical address of the region to remove
> > + * @size: size of the region to remove
> > + *
> > + * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
> > + * and online/offline operations before this call, as required by
> > + * try_offline_node().
> > + */
> > +void __remove_memory(int nid, u64 start, u64 size)
> >  {
> > +
> > +     /*
> > +      * trigger BUG() is some memory is not offlined prior to calling this
> > +      * function
> > +      */
> > +     if (try_remove_memory(nid, start, size))
> > +             BUG();
> > +}
>
> Could we call this remove_offline_memory()?  That way, it makes _some_
> sense why we would BUG() if the memory isn't offline.

Please WARN() instead of BUG() because failing to remove memory should
not be system fatal.

