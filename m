Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 488866B0039
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 17:08:11 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 0/3] ACPI / hotplug / mm: Rework mutual exclusion between hibernation and memory hotplug
Date: Thu, 29 Aug 2013 23:12:53 +0200
Message-ID: <9589253.Co8jZpnWdd@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Cc: Toshi Kani <toshi.kani@hp.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org

Hi All,

One thing that bothers me quite a bit about memory hotplug is that
lock_hotplug_memory() acquires pm_mutex which is kind of a blunt thing
and has a huge potential for deadlocks.

This can be avoided if device_hotplug_lock is held around hibernation,
which is not too difficult to make happen and hence the following patch
series.

[1/3] ACPI: Acquire device_hotplug_lock before acpi_scan_lock (this is
      necessary, because hibernation acquires acpi_scan_lock in linux-next).

[2/3] PM / hibernate: Allocate memory bitmaps after freezing user space
      processes (the reason why is explained in the changelog).

[3/3] Rework mutual exclusion between hibernation and memory hotplug.

On top of linux-pm.git/linux-next.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
