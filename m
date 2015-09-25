Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f54.google.com (mail-vk0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA166B025A
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 16:25:51 -0400 (EDT)
Received: by vkgd64 with SMTP id d64so63094755vkg.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 13:25:50 -0700 (PDT)
Received: from mail-vk0-f47.google.com (mail-vk0-f47.google.com. [209.85.213.47])
        by mx.google.com with ESMTPS id p138si2620563vkp.144.2015.09.25.13.25.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 13:25:49 -0700 (PDT)
Received: by vkao3 with SMTP id o3so62893082vka.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 13:25:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4357538.Wlf88yQie6@vostro.rjw.lan>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	<20150925185256.GG5951@linux>
	<4331507.W3ZDWldbWu@vostro.rjw.lan>
	<4357538.Wlf88yQie6@vostro.rjw.lan>
Date: Fri, 25 Sep 2015 13:25:49 -0700
Message-ID: <CAKohpok2Z2m7GZt1GzZzofeHEioF=XJEq8YVgtY=VtS9tmpb_Q@mail.gmail.com>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>

On 25 September 2015 at 13:33, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> You're going to change that into bool in the next patch, right?

Yeah.

> So what if bool is a byte and the field is not word-aligned

Its between two 'unsigned long' variables today, and the struct isn't packed.
So, it will be aligned, isn't it?

> and changing
> that byte requires a read-modify-write.  How do we ensure that things remain
> consistent in that case?

I didn't understood why a read-modify-write is special here? That's
what will happen
to most of the non-word-sized fields anyway?

Probably I didn't understood what you meant..

--
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
