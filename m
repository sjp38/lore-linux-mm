Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id E534C6B0034
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:48:21 -0400 (EDT)
Message-ID: <1374767240.16322.228.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 25 Jul 2013 09:47:20 -0600
In-Reply-To: <51F06E87.1060902@gmail.com>
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
	   <20130722083721.GC25976@gmail.com>
	   <1374513120.16322.21.camel@misato.fc.hp.com>
	   <20130723080101.GB15255@gmail.com>
	  <1374612301.16322.136.camel@misato.fc.hp.com> <51EF1D38.60503@gmail.com>
	 <1374681742.16322.180.camel@misato.fc.hp.com> <51F06E87.1060902@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hush Bensen <hush.bensen@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, kosaki.motohiro@gmail.com, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Thu, 2013-07-25 at 08:17 +0800, Hush Bensen wrote:
 :
> Thanks for your explaination, very useful for me. ;-) Btw, what's the 
> eject method done?

On bare metal, the eject method makes a target device electrically
isolated and physically removable.  On virtualized environment, the
eject method makes a target device unassigned and released.

> Could you give me the calltrace of add_memory and remove_memory? I
> don't have machine support hotplug, but I hope to investigate how
> ACPI part works for memory hotplug. ;-)

Here you go.

[   84.883517]  [<ffffffff8153e8a4>] add_memory+0x24/0x185
[   84.883525]  [<ffffffff812ca331>] ? acpi_get_pxm+0x2b/0x4e
[   84.883533]  [<ffffffff81303418>] acpi_memory_device_add+0x144/0x274
[   84.883539]  [<ffffffff812c1b25>] acpi_bus_device_attach+0x80/0xd9
[   84.883545]  [<ffffffff812c2b65>] acpi_bus_scan+0x65/0x9f
[   84.883551]  [<ffffffff812c2c1d>] acpi_scan_bus_device_check
+0x7e/0x10f
[   84.883556]  [<ffffffff812c2cc1>] acpi_scan_device_check+0x13/0x15
[   84.883562]  [<ffffffff812bbdab>] acpi_os_execute_deferred+0x25/0x32
[   84.883568]  [<ffffffff81057cbc>] process_one_work+0x229/0x3d3
[   84.883573]  [<ffffffff81057bfa>] ? process_one_work+0x167/0x3d3
[   84.883579]  [<ffffffff81058248>] worker_thread+0x133/0x200
[   84.883584]  [<ffffffff81058115>] ? rescuer_thread+0x280/0x280
[   84.883591]  [<ffffffff8105e0c3>] kthread+0xb1/0xb9
[   84.883598]  [<ffffffff8105e012>] ? __kthread_parkme+0x65/0x65
[   84.883604]  [<ffffffff81556c9c>] ret_from_fork+0x7c/0xb0
[   84.883610]  [<ffffffff8105e012>] ? __kthread_parkme+0x65/0x65

[  129.586622]  [<ffffffff8153f4b1>] remove_memory+0x22/0x85
[  129.586627]  [<ffffffff813031c6>] acpi_memory_device_remove+0x77/0xa7
[  129.586631]  [<ffffffff812c0f95>] acpi_bus_device_detach+0x3d/0x5e
[  129.586634]  [<ffffffff812c0ff8>] acpi_bus_trim+0x42/0x7a
[  129.586637]  [<ffffffff812c1587>] acpi_scan_hot_remove+0x1ba/0x261
[  129.586641]  [<ffffffff812c16ce>] acpi_bus_device_eject+0xa0/0xd0
[  129.586644]  [<ffffffff812bbdab>] acpi_os_execute_deferred+0x25/0x32
[  129.586648]  [<ffffffff81057cbc>] process_one_work+0x229/0x3d3
[  129.586652]  [<ffffffff81057bfa>] ? process_one_work+0x167/0x3d3
[  129.586655]  [<ffffffff81058248>] worker_thread+0x133/0x200
[  129.586658]  [<ffffffff81058115>] ? rescuer_thread+0x280/0x280
[  129.586663]  [<ffffffff8105e0c3>] kthread+0xb1/0xb9
[  129.586667]  [<ffffffff8105e012>] ? __kthread_parkme+0x65/0x65
[  129.586671]  [<ffffffff81556c9c>] ret_from_fork+0x7c/0xb0
[  129.586675]  [<ffffffff8105e012>] ? __kthread_parkme+0x65/0x65

-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
