Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id E3DFE6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 14:34:40 -0400 (EDT)
Message-ID: <51E83536.6070100@sr71.net>
Date: Thu, 18 Jul 2013 11:34:30 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
References: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>  <51E80973.9000308@intel.com> <1374164815.24916.84.camel@misato.fc.hp.com>
In-Reply-To: <1374164815.24916.84.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On 07/18/2013 09:26 AM, Toshi Kani wrote:
> On Thu, 2013-07-18 at 08:27 -0700, Dave Hansen wrote:
>> I'd really prefer you don't do this.  Do you really have random
>> processes on your system poking at random sysfs files and then
>> complaining when things break?
> 
> I am afraid that the "probe" interface does not provide the level of
> quality suitable for regular users.  It takes any value and blindly
> extends the page table.

That's like saying that /dev/sda takes any value and blindly writes it
to the disk.

> Also, we are not aware of the use of this
> interface on x86.  Would you elaborate why you need this interface on
> x86?  Is it for your testing, or is it necessary for end-users?  If the
> former, can you modify .config file to enable it?

For me, it's testing.  It allows testing of the memory hotplug software
stack without actual hardware, which is incredibly valuable.  That
includes testing on distribution kernels which I do not want to modify.
 I thought there were some hypervisor users which don't use ACPI for
hotplug event notifications too.

All that I'm asking is that you either leave it the way it is, or make a
Kconfig menu entry for it.

But, really, what's the problem that you're solving?  Has this caused
you issues somehow?  It's been there for, what, 10 years?  Surely it's
part of the ABI.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
