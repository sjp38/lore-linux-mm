Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 366056B0255
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 16:30:28 -0400 (EDT)
Received: by lacdq2 with SMTP id dq2so55186874lac.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 13:30:27 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id c5si2441032lbp.10.2015.09.25.13.30.26
        for <linux-mm@kvack.org>;
        Fri, 25 Sep 2015 13:30:27 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Fri, 25 Sep 2015 22:58:42 +0200
Message-ID: <2524822.pQu4UKMrlb@vostro.rjw.lan>
In-Reply-To: <CAKohpok2Z2m7GZt1GzZzofeHEioF=XJEq8YVgtY=VtS9tmpb_Q@mail.gmail.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org> <4357538.Wlf88yQie6@vostro.rjw.lan> <CAKohpok2Z2m7GZt1GzZzofeHEioF=XJEq8YVgtY=VtS9tmpb_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>

On Friday, September 25, 2015 01:25:49 PM Viresh Kumar wrote:
> On 25 September 2015 at 13:33, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > You're going to change that into bool in the next patch, right?
> 
> Yeah.
> 
> > So what if bool is a byte and the field is not word-aligned
> 
> Its between two 'unsigned long' variables today, and the struct isn't packed.
> So, it will be aligned, isn't it?
> 
> > and changing
> > that byte requires a read-modify-write.  How do we ensure that things remain
> > consistent in that case?
> 
> I didn't understood why a read-modify-write is special here? That's
> what will happen
> to most of the non-word-sized fields anyway?
> 
> Probably I didn't understood what you meant..

Say you have three adjacent fields in a structure, x, y, z, each one byte long.
Initially, all of them are equal to 0.

CPU A writes 1 to x and CPU B writes 2 to y at the same time.

What's the result?

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
