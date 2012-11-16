Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A51626B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:39:37 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 0/3] acpi: Introduce prepare_remove device operation
Date: Fri, 16 Nov 2012 22:43:59 +0100
Message-ID: <1446291.TgLDtXqY7q@vostro.rjw.lan>
In-Reply-To: <1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
References: <1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, toshi.kani@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thursday, November 15, 2012 11:22:47 AM Vasilis Liaskovitis wrote:
> As discussed in https://patchwork.kernel.org/patch/1581581/
> the driver core remove function needs to always succeed. This means we need
> to know that the device can be successfully removed before acpi_bus_trim / 
> acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
> eject or driver unbind of memory devices fails e.g with:
> 
> echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> 
> since the ACPI core goes ahead and ejects the device regardless of whether the
> the memory is still in use or not.

So the question is, does the ACPI core have to do that and if so, then why?

Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
