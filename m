Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 26CC56B0254
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 09:42:32 -0400 (EDT)
Received: by laer8 with SMTP id r8so7013127lae.2
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 06:42:31 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id p4si5977809lbw.11.2015.09.27.06.42.30
        for <linux-mm@kvack.org>;
        Sun, 27 Sep 2015 06:42:30 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Sun, 27 Sep 2015 16:10:48 +0200
Message-ID: <1578470.DLzaBp4j3T@vostro.rjw.lan>
In-Reply-To: <1540878.9slRi6Q7xb@wuerfel>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org> <CAKohpok0A3JRhVCabscfJGuhJerWmypsQnwdqJcmvBBWdpvPwQ@mail.gmail.com> <1540878.9slRi6Q7xb@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, Viresh Kumar <viresh.kumar@linaro.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Intel Linux Wireless <ilw@linux.intel.com>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Johannes Berg <johannes@sipsolutions.net>, Linux Memory Management List <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>

On Saturday, September 26, 2015 09:33:56 PM Arnd Bergmann wrote:
> On Saturday 26 September 2015 11:40:00 Viresh Kumar wrote:
> > On 25 September 2015 at 15:19, Rafael J. Wysocki <rafael@kernel.org> wrote:
> > > So if you allow something like debugfs to update your structure, how
> > > do you make sure there is the proper locking?
> > 
> > Not really sure at all.. Isn't there some debugfs locking that will
> > jump in, to avoid updation of fields to the same device?
> 
> No, if you need any locking to access variable, you cannot use the
> simple debugfs helpers but have to provide your own functions.
> 
> > >> Anyway, that problem isn't here for sure as its between two
> > >> unsigned-longs. So, should I just move it to bool and resend ?
> > >
> > > I guess it might be more convenient to fold this into the other patch,
> > > because we seem to be splitting hairs here.
> > 
> > I can and that's what I did. But then Arnd asked me to separate it
> > out. I can fold it back if that's what you want.
> 
> It still makes sense to keep it separate I think, the patch is clearly
> different from the other parts.

I just don't see much point in going from unsigned long to u32 and then
from 32 to bool if we can go directly to bool in one go.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
