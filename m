Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54B85C43612
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 16:25:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 144A820874
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 16:25:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="GynMm4CM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 144A820874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AF0C8E0002; Fri, 11 Jan 2019 11:25:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95DCF8E0001; Fri, 11 Jan 2019 11:25:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84FE88E0002; Fri, 11 Jan 2019 11:25:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59E0C8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:25:31 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id m52so6347714otc.13
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:25:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oAkInDyjniJpNrxeYSro+8Xc80fV7Ji6IK0jrUn2go4=;
        b=esQvfoG/+4I8wolBdit05W44aV/ucRzDkK+ld7lxli/kptmiHhp0gyG3vvNKUr+jhn
         f5/2YNKKAXz9ZCvJFVyB769aqSEwpdCoF/5xJnccnxyIVm2UYUP9UiG49qZElkX0O5LG
         OMhcFWr3Eg9cOplEL+Py7oKCudGt6iDvVz7ys7uJuXo5IbytS+ucWwlgAgLPvGTWaQDY
         Oug5FK7CvfrcXXGqNcr3LoVHEgpezNO93vCI96EFUIQ81dMoH8gPvYkA7ytH0kkLKSDW
         6WDpRnbvWpfChrEGhzfYtLOM5Qf0/LiGJjHUw9Ic/yg2Q/L53FPx9+xdnZ7BT3teBvar
         1mfQ==
X-Gm-Message-State: AJcUukczk5q+y2onYJwJyWUVBkBMDIVzeNnHZSFzqqatrn3vKnpm49wy
	LQtFbt8CtLUTuk5Jl9qJPXlvxm0nQfAwYU6m9uQ2EbTxSArEhHcqqAhawu9Cu01LP1pzAY3PwU8
	gLqXE5TPHNcBzh6EWSLc81n+5RWLsxUKl5nQO77vqpdB6Y1CndmGUCpMkJ6yzBL62k23zYnAKiw
	LFyb21Ou0mlYwhc9NT5LiUqkd0MO0b83pFhUrJdy2DZx8mUicxbJYNbxFu6+FvsxBUOo3K3hroX
	ubh2xvCQ0A0sIXOn8G5kUCuuESK27sOOwjD06q2GOAgIiFr6e5CU23zXbys7qSAMJFkd2dEJUqw
	LqCp6ikk0cjhwjFIlFbq+Gfi0vdiiAg+N0ipYQWfL0+No4+kteuabyj9n02+Ci9SJhqkVo+3L6Z
	z
X-Received: by 2002:a9d:75da:: with SMTP id c26mr10797718otl.39.1547223930886;
        Fri, 11 Jan 2019 08:25:30 -0800 (PST)
X-Received: by 2002:a9d:75da:: with SMTP id c26mr10797688otl.39.1547223930175;
        Fri, 11 Jan 2019 08:25:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547223930; cv=none;
        d=google.com; s=arc-20160816;
        b=ltcYbhhEWFaejQ1fuLgvK/HUiYHiwKw/iQ1atxik7+vksq8M7Hwf7X0rEFVm/VQQu4
         iK6kU1Pc6R80y5uyGFWPTwMHJkVjm7FZj4WpQH8IWvAqdpnIVletN/wRglcCJO4zxJm6
         76bdT6kwXonRH1CkV6dos0GJyASNANiyGk5hS4jsGF97MQaygl9t40UIjq2FFuQHvfge
         TuFBvPhapbbBoskvp0/6GGlqK6adzPdSENyHDB1WK/1R2GoT1rLPS2bW3ge39YzRMbkP
         xnoOJ5biOX+EiexwGIdt5Lq/NU7g6252WApq6qM4jCme35oR5KB+ytA6/d5m+xZDJFqM
         g44w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oAkInDyjniJpNrxeYSro+8Xc80fV7Ji6IK0jrUn2go4=;
        b=YkrIRUxDSC4lFPQlA58ZqMmpFcUMSSV8S0NkAlX6aPU93nXOAX0O/4xTilFZ4gIiZt
         MLo4G2Xj6Xh6yb7kzRBEzaZRYM+VtdMQ7SaS9gATZBP7Zyvobgx4GH22CCS6mXLO6/lX
         Hn35WTQhSdQGtWAVmHbSg4mH3Sx3/w6pA4bRjfpS5hLPUwfEvqIkygfQiJmSUPoZWEtC
         IWUtDzJFMBM3ksj4bKW8QoQoAgkloXuKhScQjf0srHIcxYKBvHqijS+OLSr87Vecev8p
         q9XB1uduKVfx7yON/KGrM+saM8eaASv8FkTOHqtW8tzEqEngsXvwjK4U7qvcE1gj4HNE
         YTbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GynMm4CM;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 38sor47092982otb.40.2019.01.11.08.25.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 08:25:29 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GynMm4CM;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oAkInDyjniJpNrxeYSro+8Xc80fV7Ji6IK0jrUn2go4=;
        b=GynMm4CMejh1CwRzf9A5mk1pWbr1Kd7YN4HkcRh0SLOuwUfT8P8jdMFuhN10SBogUJ
         Do8PjmFDOBpbAaYUFfVreWWY4Vgd0zdGOIKela17q10Ujo05+Juu0zJu2oUbdqe4RD+g
         sbnRbAiOh8+QLsKzjcjrJi4VcPYh4ihsYH1icy+WmDYokiV+SArrHsheCiXshTTLeN6A
         +WqHnY5YbXvc7zG3ESPYISgBEFRj3jFvnoXvTDWs8Wp8L4bVEwEZPgykBGTVHxmvBOdJ
         RJ/lUd4zYBO8AJQKr6bvpJz/A9OHAKDNIpuf6X5cc2hm8eBpN3LdvxIbfmWQJERBTydQ
         uxoA==
X-Google-Smtp-Source: ALg8bN4juSUyLT5TiC6ZYmBOsMFiVeEo/fF1pAQSKTQvyitw1gQKkGL24KkgZL4/phyJvWIxsVh33MhapuF8DDSXxtg=
X-Received: by 2002:a9d:6a50:: with SMTP id h16mr9413162otn.95.1547223929462;
 Fri, 11 Jan 2019 08:25:29 -0800 (PST)
MIME-Version: 1.0
References: <20190109174341.19818-1-keith.busch@intel.com> <20190109174341.19818-8-keith.busch@intel.com>
 <87y37sit8x.fsf@linux.ibm.com> <20190110173016.GC21095@localhost.localdomain>
 <20190111113238.000068b0@huawei.com> <20190111155828.GD21095@localhost.localdomain>
In-Reply-To: <20190111155828.GD21095@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 11 Jan 2019 08:25:17 -0800
Message-ID:
 <CAPcyv4iHxyQkCScMzDM3YyuP6+zhqvNXtYHg_rdhgrOq9tevbg@mail.gmail.com>
Subject: Re: [PATCHv3 07/13] node: Add heterogenous memory access attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111162517.DPi6A-uzBT_i2SFQb9yH5xqHgu-JSf4phFqR8MaXv7E@z>

On Fri, Jan 11, 2019 at 7:59 AM Keith Busch <keith.busch@intel.com> wrote:
>
> On Fri, Jan 11, 2019 at 11:32:38AM +0000, Jonathan Cameron wrote:
> > On Thu, 10 Jan 2019 10:30:17 -0700
> > Keith Busch <keith.busch@intel.com> wrote:
> > > I am not aware of a real platform that has an initiator-target pair with
> > > better latency but worse bandwidth than any different initiator paired to
> > > the same target. If such a thing exists and a subsystem wants to report
> > > that, you can register any arbitrary number of groups or classes and
> > > rank them according to how you want them presented.
> > >
> >
> > It's certainly possible if you are trading off against pin count by going
> > out of the soc on a serial bus for some large SCM pool and also have a local
> > SCM pool on a ddr 'like' bus or just ddr on fairly small number of channels
> > (because some one didn't put memory on all of them).
> > We will see this fairly soon in production parts.
> >
> > So need an 'ordering' choice for this circumstance that is predictable.
>
> As long as the reported memory target access attributes are accurate for
> the initiator nodes listed under an access class, I'm not sure that it
> matters what order you use. All the information needed to make a choice
> on which pair to use is available, and the order is just an implementation
> specific decision.

Agree with Keith. If the performance is differentiated it will be in a
separate class. A hierarchy of classes is not enforced by the
interface, but it tries to advertise some semblance of the "best"
initiator pairing for a given target by default with the flexibility
to go more complex if the situation arises.

As was seen in the SCSI specification efforts to advertise all manner
of cache hinting the kernel community discovered that only a small
fraction of what hardware vendors thought mattered actually
demonstrated value in practice. That experience is instructive that
the kernel interfaces for hardware performance hints should prioritize
what makes sense for the kernel and applications generally, not
necessarily every conceivable performance detail that a hardware
platform chooses to expose, or niche applications might consume.

