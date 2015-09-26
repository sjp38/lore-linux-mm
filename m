Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f51.google.com (mail-vk0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFA16B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 14:40:01 -0400 (EDT)
Received: by vkgd64 with SMTP id d64so72539407vkg.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 11:40:01 -0700 (PDT)
Received: from mail-vk0-f54.google.com (mail-vk0-f54.google.com. [209.85.213.54])
        by mx.google.com with ESMTPS id p143si4374209vkp.116.2015.09.26.11.40.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 11:40:00 -0700 (PDT)
Received: by vkfp126 with SMTP id p126so72444056vkf.3
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 11:40:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0i+xJ4U13vCVsvXc7S8wP0AokbmNXPidBkDwbjXMM8fCw@mail.gmail.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	<4357538.Wlf88yQie6@vostro.rjw.lan>
	<CAKohpok2Z2m7GZt1GzZzofeHEioF=XJEq8YVgtY=VtS9tmpb_Q@mail.gmail.com>
	<2524822.pQu4UKMrlb@vostro.rjw.lan>
	<20150925214438.GH5951@linux>
	<CAJZ5v0i+xJ4U13vCVsvXc7S8wP0AokbmNXPidBkDwbjXMM8fCw@mail.gmail.com>
Date: Sat, 26 Sep 2015 11:40:00 -0700
Message-ID: <CAKohpok0A3JRhVCabscfJGuhJerWmypsQnwdqJcmvBBWdpvPwQ@mail.gmail.com>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>

On 25 September 2015 at 15:19, Rafael J. Wysocki <rafael@kernel.org> wrote:
> So if you allow something like debugfs to update your structure, how
> do you make sure there is the proper locking?

Not really sure at all.. Isn't there some debugfs locking that will
jump in, to avoid updation of fields to the same device?

> Is that not a problem in all of the places modified by the [2/2]?

Right, but its not new AFAICT.

We already have u32 fields in those structs and on 64 bit machines
we have the same read-update-write problems for two consecutive
u32's. Right?

> How can the future users of the API know what to do to avoid potential
> problems with it?

No idea really :)

>> Anyway, that problem isn't here for sure as its between two
>> unsigned-longs. So, should I just move it to bool and resend ?
>
> I guess it might be more convenient to fold this into the other patch,
> because we seem to be splitting hairs here.

I can and that's what I did. But then Arnd asked me to separate it
out. I can fold it back if that's what you want.

--
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
