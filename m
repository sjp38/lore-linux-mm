Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB3E680DC6
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 05:54:09 -0400 (EDT)
Received: by qgx61 with SMTP id 61so127995296qgx.3
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 02:54:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e195si18313966qka.109.2015.10.04.02.54.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Oct 2015 02:54:08 -0700 (PDT)
Date: Sun, 4 Oct 2015 10:54:01 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH V5 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
Message-ID: <20151004095401.GA29706@kroah.com>
References: <8d3d3428c3a36f821e4c3d8563d094ca4b4763fd.1443304934.git.viresh.kumar@linaro.org>
 <CAJZ5v0imYBPVNfVjkgX1r8a1x6QbY4LtRcS7BNsGzg5=yuPRfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0imYBPVNfVjkgX1r8a1x6QbY4LtRcS7BNsGzg5=yuPRfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Lists linaro-kernel <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, netdev@vger.kernel.org, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>

On Sun, Sep 27, 2015 at 03:48:24PM +0200, Rafael J. Wysocki wrote:
> On Sun, Sep 27, 2015 at 12:04 AM, Viresh Kumar <viresh.kumar@linaro.org> wrote:
> > global_lock is defined as an unsigned long and accessing only its lower
> > 32 bits from sysfs is incorrect, as we need to consider other 32 bits
> > for big endian 64-bit systems. There are no such platforms yet, but the
> > code needs to be robust for such a case.
> >
> > Fix that by changing type of 'global_lock' to u32.
> >
> > Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> 
> Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Greg, please take this one along with the [2/2] if that one looks good to you.

Thanks, will do.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
