Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CB60C6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 18:19:57 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so38315123wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 15:19:57 -0700 (PDT)
Received: from mail-wi0-x241.google.com (mail-wi0-x241.google.com. [2a00:1450:400c:c05::241])
        by mx.google.com with ESMTPS id fl12si1968048wjc.60.2015.09.25.15.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 15:19:56 -0700 (PDT)
Received: by wicxq10 with SMTP id xq10so5516519wic.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 15:19:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150925214438.GH5951@linux>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	<4357538.Wlf88yQie6@vostro.rjw.lan>
	<CAKohpok2Z2m7GZt1GzZzofeHEioF=XJEq8YVgtY=VtS9tmpb_Q@mail.gmail.com>
	<2524822.pQu4UKMrlb@vostro.rjw.lan>
	<20150925214438.GH5951@linux>
Date: Sat, 26 Sep 2015 00:19:56 +0200
Message-ID: <CAJZ5v0i+xJ4U13vCVsvXc7S8wP0AokbmNXPidBkDwbjXMM8fCw@mail.gmail.com>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
From: "Rafael J. Wysocki" <rafael@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>

On Fri, Sep 25, 2015 at 11:44 PM, Viresh Kumar <viresh.kumar@linaro.org> wrote:
> On 25-09-15, 22:58, Rafael J. Wysocki wrote:
>> Say you have three adjacent fields in a structure, x, y, z, each one byte long.
>> Initially, all of them are equal to 0.
>>
>> CPU A writes 1 to x and CPU B writes 2 to y at the same time.
>>
>> What's the result?
>
> But then two CPUs can update the same variable as well, and we must
> have proper locking in place to fix that.

Right.

So if you allow something like debugfs to update your structure, how
do you make sure there is the proper locking?

Is that not a problem in all of the places modified by the [2/2]?

How can the future users of the API know what to do to avoid potential
problems with it?

>
> Anyway, that problem isn't here for sure as its between two
> unsigned-longs. So, should I just move it to bool and resend ?

I guess it might be more convenient to fold this into the other patch,
because we seem to be splitting hairs here.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
