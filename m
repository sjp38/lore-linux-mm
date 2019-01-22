Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D147DC282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 16:52:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 971A221019
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 16:52:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 971A221019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37B7E8E0003; Tue, 22 Jan 2019 11:52:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32BBD8E0001; Tue, 22 Jan 2019 11:52:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 243C38E0003; Tue, 22 Jan 2019 11:52:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id F06968E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:52:08 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id g4so9839893otl.14
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:52:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=lcquk7P9RYTtB49NXyYLu5SF++ESl8Lz8Zlf08rA2OQ=;
        b=hoUu6h4G0tWaLQlknlwcl3qCX3q+c2GUjXSm/nwfHveM4oev6d8NzvOFUNcKE42r9E
         KDEjm6VSc00OnlKVmLFrHeuHMHlSf5QbFN9GklJy0xTvDTMJt6BF2PecMEH5Ngwj6iLY
         krrs/O9DI/LmgzaPw+kg/IZ+tHP3hjqrBu4+J8/B+JwE7JdyFB0HMh3v2yyhOZFjlTcA
         kOwdk9QQWy3PRbDOAY7TJ+vtwxgFfOAuAS3+Vz82jdWBO6Nfxj+VR7pa4M8sIbr97P/W
         ahzatQJw+5Ik4Jc0kf0UuoOnuO+m21btiF5gHqtPtAEa7ml3mPMiOr6cMDks7DRJywEs
         oygw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeBaqbfMCzP95kGGLrTwrU+AJMEyfVP2oMBSassDqWyDXe28C9u
	bbDbQuMegL+sTh2orWawWoV8g6XJp9iw/VqvfnOKqSzxCijCJnCiyxIW7npLBJXJWibJod9WfeG
	2tMMpPd0FRcXSG4oPu21CLcrJurzrebgnZ5QB69fkb6QssZgJeUO8THlo4ilYTIgLJ85QE43SmU
	Q1BlFqCexGC6ndT03lpuyN550HkF783k5+4Y4+l6BsWS+zjNMAl4ZuYLov6KH7HxtlkgM8m3gzP
	dRODCFI8hARZmX1cyO2TFV2NnxuFlv3tm28Mdk/bo0WrrnJZOK8q3pBKjgbftRUQS4g6pVg+tb5
	eMb3LECrhiweT0nrGl54GV1sZyv5aXTHYV1xZ8lOm8dCvHsKiHqSW8YSs7Mxzw4GCfjQuvsLSA=
	=
X-Received: by 2002:aca:6155:: with SMTP id v82mr9008277oib.259.1548175928585;
        Tue, 22 Jan 2019 08:52:08 -0800 (PST)
X-Received: by 2002:aca:6155:: with SMTP id v82mr9008253oib.259.1548175927885;
        Tue, 22 Jan 2019 08:52:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548175927; cv=none;
        d=google.com; s=arc-20160816;
        b=gK2vG6D8pB6I7gwPX4a6SwYjTwv+cERq0l79wL1YNseqL7+4xVbgAAXH02sISfJcmW
         mDsm85ufz26c9fIWgxnSseOvuMp/l1Fna3VkLRTPglrVVAouDn5p0rjD6JRuGNI2Bgeg
         CoEiymG886RXt6fXL9T7oTerH/Oq0nS4QghEiKNv7xjjx8C4QLNplcilDD5abTbVtszW
         +AWcYdYdo8zIiSl9MjGaVAm52oK36RCgGTRNW//nOaz4RME8BTveeJysYZtW60Gfhelo
         a/HV5bO/m8iSXsx7IFxSpFpZ0aBkhCIMiU4sLOPn5oxmQ96i66l0SgsM55hM4zz/y10z
         CMlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=lcquk7P9RYTtB49NXyYLu5SF++ESl8Lz8Zlf08rA2OQ=;
        b=wtLr+h70GC1iZcDTMBzNnPeoLXNrNB81W40kBaxsWMLw8YKYXGVOXEc78JSSiOey04
         0zHkigZJZezuqgApXuvv/eVQ2Ou+oXBT8pUQUeRVmkdbtmJg6ZZULbTJo2MZ1NiZlL2x
         Zu+P4Voj1ree57scEC0+/B1HT9oZGGo/yshU/oUMy6SRZBH02kIm3VQZ3g38+wuM+Aor
         l2rHOrV9lxQLeIvTz/UWw5WF0IMQODvzJDO32Whs43SrmzcyPv2Obzw8MmWMoPYq2NjT
         Dsq6xi5DBsiBK4VKjBVH5oQ8VGeOo0CIBm2w7wxolBRQ/zqMwGRhWc68LYZiD/ZwgOMU
         Mm8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k73sor5498146oib.99.2019.01.22.08.52.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 08:52:07 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN7d1xdko8em0OzR4GgCbybm4YWTo08AJPrsbv4p1VXfHzEvo1XpAO/zfpjyfr5Oxm48bn2vYKFcE+hsSI/PdLU=
X-Received: by 2002:aca:195:: with SMTP id 143mr8334859oib.322.1548175927484;
 Tue, 22 Jan 2019 08:52:07 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
 <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com>
 <20190119090129.GC10836@kroah.com> <CAJZ5v0jxuLPUvwr-hYstgC-7BKDwqkJpep94rnnUFvFhKG4W3g@mail.gmail.com>
 <20190122163650.GD1477@localhost.localdomain>
In-Reply-To: <20190122163650.GD1477@localhost.localdomain>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 22 Jan 2019 17:51:56 +0100
Message-ID:
 <CAJZ5v0ggO9DePeYJkEoZ-ymB5VQywBgTnsGBo4WPHD5_JrjKRA@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Dan Williams <dan.j.williams@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190122165156.3V29zHr3OKulOY8oDIEOCDQCxewB2l4pnw7HjHOrlto@z>

On Tue, Jan 22, 2019 at 5:37 PM Keith Busch <keith.busch@intel.com> wrote:
>
> On Sun, Jan 20, 2019 at 05:16:05PM +0100, Rafael J. Wysocki wrote:
> > On Sat, Jan 19, 2019 at 10:01 AM Greg Kroah-Hartman
> > <gregkh@linuxfoundation.org> wrote:
> > >
> > > If you do a subdirectory "correctly" (i.e. a name for an attribute
> > > group), that's fine.
> >
> > Yes, that's what I was thinking about: along the lines of the "power"
> > group under device kobjects.
>
> We can't append symlinks to an attribute group, though.

That's right, unfortunately.

> I'd need to create a lot of struct devices just to get the desired directory hiearchy.

No, you don't need to do that.  Kobjects can be added without
registering a struct device for each of them kind of along the lines
of what cpufreq does for its policy objects etc.  See
cpufreq_policy_alloc() and cpufreq_core_init() for examples.

> And then each of those "devices" will have their own "power" group, which
> really doesn't make any sense for what we're trying to show. Is that
> really the right way to do this, or something else I'm missing?

Above?

