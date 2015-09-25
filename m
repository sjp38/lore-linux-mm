Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id C166F6B0256
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 15:54:19 -0400 (EDT)
Received: by laclj5 with SMTP id lj5so14429113lac.3
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:54:19 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id zk1si2378710lbb.30.2015.09.25.12.54.17
        for <linux-mm@kvack.org>;
        Fri, 25 Sep 2015 12:54:18 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Fri, 25 Sep 2015 22:22:33 +0200
Message-ID: <16046206.NvsuxYn5NN@vostro.rjw.lan>
In-Reply-To: <1460975.zriLPuubXp@vostro.rjw.lan>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org> <1460975.zriLPuubXp@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linaro-kernel@lists.linaro.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org, linux-edac@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Friday, September 25, 2015 10:18:13 PM Rafael J. Wysocki wrote:
> On Friday, September 25, 2015 09:41:37 AM Viresh Kumar wrote:
> > global_lock is defined as an unsigned long and accessing only its lower
> > 32 bits from sysfs is incorrect, as we need to consider other 32 bits
> > for big endian 64 bit systems. There are no such platforms yet, but the
> > code needs to be robust for such a case.
> > 
> > Fix that by passing a local variable to debugfs_create_bool() and
> > assigning its value to global_lock later.
> > 
> > Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> 
> Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Greg, please take this one if the [2/2] looks good to you.

Ouch, turns out it was a bad idea.  Please scratch that.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
