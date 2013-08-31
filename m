Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A781C6B0032
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 20:19:10 -0400 (EDT)
Message-ID: <1377908257.10300.896.camel@misato.fc.hp.com>
Subject: Re: [PATCH 1/3] ACPI / scan: Change ordering of locks for device
 hotplug
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 30 Aug 2013 18:17:37 -0600
In-Reply-To: <1752041.76DW3TEE1A@vostro.rjw.lan>
References: <9589253.Co8jZpnWdd@vostro.rjw.lan>
	 <1752041.76DW3TEE1A@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 2013-08-29 at 23:15 +0200, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Change the ordering of device hotplug locks in scan.c so that
> acpi_scan_lock is always acquired after device_hotplug_lock.
> 
> This will make it possible to use device_hotplug_lock around some
> code paths that acquire acpi_scan_lock safely (most importantly
> system suspend and hibernation).  Apart from that, acpi_scan_lock
> is platform-specific and device_hotplug_lock is general, so the
> new ordering appears to be more appropriate from the overall
> design viewpoint.
> 
> Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
