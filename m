Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D46556B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 15:34:17 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so58060435wic.1
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 12:34:17 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id dj1si11980890wjc.70.2015.09.26.12.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 12:34:16 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Sat, 26 Sep 2015 21:33:56 +0200
Message-ID: <1540878.9slRi6Q7xb@wuerfel>
In-Reply-To: <CAKohpok0A3JRhVCabscfJGuhJerWmypsQnwdqJcmvBBWdpvPwQ@mail.gmail.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org> <CAJZ5v0i+xJ4U13vCVsvXc7S8wP0AokbmNXPidBkDwbjXMM8fCw@mail.gmail.com> <CAKohpok0A3JRhVCabscfJGuhJerWmypsQnwdqJcmvBBWdpvPwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-kernel@lists.linaro.org
Cc: Viresh Kumar <viresh.kumar@linaro.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Intel Linux Wireless <ilw@linux.intel.com>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Johannes Berg <johannes@sipsolutions.net>, Linux Memory Management List <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>

On Saturday 26 September 2015 11:40:00 Viresh Kumar wrote:
> On 25 September 2015 at 15:19, Rafael J. Wysocki <rafael@kernel.org> wrote:
> > So if you allow something like debugfs to update your structure, how
> > do you make sure there is the proper locking?
> 
> Not really sure at all.. Isn't there some debugfs locking that will
> jump in, to avoid updation of fields to the same device?

No, if you need any locking to access variable, you cannot use the
simple debugfs helpers but have to provide your own functions.

> >> Anyway, that problem isn't here for sure as its between two
> >> unsigned-longs. So, should I just move it to bool and resend ?
> >
> > I guess it might be more convenient to fold this into the other patch,
> > because we seem to be splitting hairs here.
> 
> I can and that's what I did. But then Arnd asked me to separate it
> out. I can fold it back if that's what you want.

It still makes sense to keep it separate I think, the patch is clearly
different from the other parts.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
