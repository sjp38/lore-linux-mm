Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00677C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:23:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5DBA218F0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:23:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5DBA218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53A826B0003; Thu, 25 Jul 2019 17:23:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C4798E0002; Thu, 25 Jul 2019 17:23:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 364B46B0006; Thu, 25 Jul 2019 17:23:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05D096B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:23:50 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id m24so7145225oih.16
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:23:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=ymU59qUw9f+YTxwPbG7+MzBEYroVA+eRo9XyYVrY9Y0=;
        b=JmZedi+CQVs79ZtwhTiiYXZfcq1aji0sUxX9lYZjYUvXtXW4a9zzSXBZMm9if9jDJR
         KLA4WBNfLBP5e8y0cs/uYyj58ko7+BOhp894d8V8MSo/n4qjUaTzgPp93YWag3jW4pxY
         oGLFv2OoDik50XtmUZCXCBdtSDSLNg1YPu9CipdUdsXpeBSlVLIUJE/DTnOMZEUNIC3l
         a7Vpb59v4cyxmCQCPgznV1rmhDEyAWBJ9K++oH/BY7wmVQlWr3dMnRlSdOHMbW0uhdcn
         cQ7ss+14tmc/hQdeL1GN5ghqIPgFgwjjRlvUmxGnTt0GObIfRF8fz3FC4MiQxf/2ETYM
         W1Ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWP5+R3iYNzhdJ+WRGm9RH4amB7nsKLd/zesN4OVcrNxxlKXFBU
	FK7ZHYv8/SDe1xW2I1judenHmes8IWuyMpM4TBRHHhIh6MQ3nhslWfX8Jj9Q/UR/4QKuKGKGn8K
	6/ctcZap4WlL2M8hYEiqCjy/u5ImLxX0n24BkAGH+oN1kGWo7O48EmOW1VgdTh/g=
X-Received: by 2002:a54:441a:: with SMTP id k26mr7372871oiw.83.1564089829583;
        Thu, 25 Jul 2019 14:23:49 -0700 (PDT)
X-Received: by 2002:a54:441a:: with SMTP id k26mr7372842oiw.83.1564089828675;
        Thu, 25 Jul 2019 14:23:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564089828; cv=none;
        d=google.com; s=arc-20160816;
        b=qzeZweHw8eKgqhbbyzYzdqpA985ZUXsjxuti6HR35tHOtE930qwR5gZFDXHmeMZMpX
         IjX6+2RK1jaQRORuHron5bPTGXC2z6ZV4UhP9+/VuNYEOKq0eBclmHgt1OpNfzUyvGuI
         LAVo2cK1xqjdTRBqRAf1g8lIt4p6awAR0Cb4SyDSOxMbwGYpq4xvaGzFsK8oKh7vOm6X
         v1pbPBL0LV+gsOklH+TdW5w+W1xLRwZp777gtFLBD2WxQ1V1idEPDmnBT83LP4T6S5Hd
         QSVcdxqSu5KhFuJrp+ZJeY2DYUn5ZcfTQqgwbCB5QKWuSv76uLcZPnSAnK2vkGQbJRyg
         DV+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=ymU59qUw9f+YTxwPbG7+MzBEYroVA+eRo9XyYVrY9Y0=;
        b=Riox1xNu5Uovft+mMEwE1gRIa2TONPEMOmhVVBf0qEh4bgt4ML/cvCVbA74pil7zBr
         +4zzNBCwDP7/Tq9NJ1J4SSbjKHR/6aTfdVVFHrFA/g7eYF7+tqQbMXkUGT/qq2P7fhUv
         1NpHUUMQLYQcvX0buM1RHknWUYU0gnqB+/K/rJNV8hfnyLlwDvEcSe8h8qNlbblCU2V8
         j7lqOsj0brLcZxDUbfAF1ZKeczsYlerQUlBVlcqRgjsizaBBXo0NnP8Gq6PAJa3Wp+sQ
         Zeuly1H7h1neHXH2Ih3Wn6+kXlA4zuLocpuXYvZHcP/j1637JygOdt5SpHqqAN0pVHjI
         CS2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p67sor23293107oic.154.2019.07.25.14.23.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 14:23:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqyvlhdC/BZI1W/nxzJZ72rWrJHG8Ltb0e8ZMHIC8wvEkvppGARCCAW+v73DBm/IDsBdOykCZuSDfEu2WefnQ+k=
X-Received: by 2002:aca:d907:: with SMTP id q7mr43310361oig.68.1564089828123;
 Thu, 25 Jul 2019 14:23:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190724143017.12841-1-david@redhat.com> <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com> <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com> <20190725191943.GA6142@dhcp22.suse.cz>
 <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
In-Reply-To: <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 25 Jul 2019 23:23:37 +0200
Message-ID: <CAJZ5v0h+MjC3gFm1Kf3eBg2Rs12368j6S_i5_Gc24yWx+Z3xBA@mail.gmail.com>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in acpi_scan_init()
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, 
	Oscar Salvador <osalvador@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 10:49 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 25.07.19 21:19, Michal Hocko wrote:
> > On Thu 25-07-19 16:35:07, David Hildenbrand wrote:
> >> On 25.07.19 15:57, Michal Hocko wrote:
> >>> On Thu 25-07-19 15:05:02, David Hildenbrand wrote:
> >>>> On 25.07.19 14:56, Michal Hocko wrote:
> >>>>> On Wed 24-07-19 16:30:17, David Hildenbrand wrote:
> >>>>>> We end up calling __add_memory() without the device hotplug lock held.
> >>>>>> (I used a local patch to assert in __add_memory() that the
> >>>>>>  device_hotplug_lock is held - I might upstream that as well soon)
> >>>>>>
> >>>>>> [   26.771684]        create_memory_block_devices+0xa4/0x140
> >>>>>> [   26.772952]        add_memory_resource+0xde/0x200
> >>>>>> [   26.773987]        __add_memory+0x6e/0xa0
> >>>>>> [   26.775161]        acpi_memory_device_add+0x149/0x2b0
> >>>>>> [   26.776263]        acpi_bus_attach+0xf1/0x1f0
> >>>>>> [   26.777247]        acpi_bus_attach+0x66/0x1f0
> >>>>>> [   26.778268]        acpi_bus_attach+0x66/0x1f0
> >>>>>> [   26.779073]        acpi_bus_attach+0x66/0x1f0
> >>>>>> [   26.780143]        acpi_bus_scan+0x3e/0x90
> >>>>>> [   26.780844]        acpi_scan_init+0x109/0x257
> >>>>>> [   26.781638]        acpi_init+0x2ab/0x30d
> >>>>>> [   26.782248]        do_one_initcall+0x58/0x2cf
> >>>>>> [   26.783181]        kernel_init_freeable+0x1bd/0x247
> >>>>>> [   26.784345]        kernel_init+0x5/0xf1
> >>>>>> [   26.785314]        ret_from_fork+0x3a/0x50
> >>>>>>
> >>>>>> So perform the locking just like in acpi_device_hotplug().
> >>>>>
> >>>>> While playing with the device_hotplug_lock, can we actually document
> >>>>> what it is protecting please? I have a bad feeling that we are adding
> >>>>> this lock just because some other code path does rather than with a good
> >>>>> idea why it is needed. This patch just confirms that. What exactly does
> >>>>> the lock protect from here in an early boot stage.
> >>>>
> >>>> We have plenty of documentation already
> >>>>
> >>>> mm/memory_hotplug.c
> >>>>
> >>>> git grep -C5 device_hotplug mm/memory_hotplug.c
> >>>>
> >>>> Also see
> >>>>
> >>>> Documentation/core-api/memory-hotplug.rst
> >>>
> >>> OK, fair enough. I was more pointing to a documentation right there
> >>> where the lock is declared because that is the place where people
> >>> usually check for documentation. The core-api documentation looks quite
> >>> nice. And based on that doc it seems that this patch is actually not
> >>> needed because neither the online/offline or cpu hotplug should be
> >>> possible that early unless I am missing something.
> >>
> >> I really prefer to stick to locking rules as outlined on the
> >> interfaces if it doesn't hurt. Why it is not needed is not clear.
> >>
> >>>
> >>>> Regarding the early stage: primarily lockdep as I mentioned.
> >>>
> >>> Could you add a lockdep splat that would be fixed by this patch to the
> >>> changelog for reference?
> >>>
> >>
> >> I have one where I enforce what's documented (but that's of course not
> >> upstream and therefore not "real" yet)
> >
> > Then I suppose to not add locking for something that is not a problem.
> > Really, think about it. People will look at this code and follow the
> > lead without really knowing why the locking is needed.
> > device_hotplug_lock has its purpose and if the code in question doesn't
> > need synchronization for the documented scenarios then the locking
> > simply shouldn't be there. Adding the lock just because of a
> > non-existing, and IMHO dubious, lockdep splats is just wrong.
> >
> > We need to rationalize the locking here, not to add more hacks.
>
> No, sorry. The real hack is calling a function that is *documented* to
> be called under lock without it. That is an optimization for a special
> case. That is the black magic in the code.
>
> The only alternative I see to this patch is adding a comment like
>
> /*
>  * We end up calling __add_memory() without the device_hotplug_lock
>  * held. This is fine as we cannot race with other hotplug activities
>  * and userspace trying to online memory blocks.
>  */
>
> Personally, I don't think that's any better than just grabbing the lock
> as we are told to. (honestly, I don't see how optimizing away the lock
> here is of *any* help to optimize our overall memory hotplug locking)
>
> @Rafael, what's your take? lock or comment?

Well, I have ACKed your patch already. :-)

That said, adding a comment stating that the lock is acquired mostly
for consistency wouldn't hurt.

