Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id BC61C6B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 19:52:07 -0400 (EDT)
Message-ID: <1374105078.24916.62.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 17 Jul 2013 17:51:18 -0600
In-Reply-To: <CAHGf_=q-9C4JZgv9Xp1Z3_Ks1a7t_sOArD3e1myj1EdiH5GBHQ@mail.gmail.com>
References: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>
	 <CAHGf_=pND-R=qMHg7b=Fi5SqS6ahXJCG865WsOS2eKWa6g3A7A@mail.gmail.com>
	 <1374103783.24916.49.camel@misato.fc.hp.com>
	 <CAHGf_=q-9C4JZgv9Xp1Z3_Ks1a7t_sOArD3e1myj1EdiH5GBHQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, "vasilis.liaskovitis" <vasilis.liaskovitis@profitbricks.com>

On Wed, 2013-07-17 at 19:33 -0400, KOSAKI Motohiro wrote:
> On Wed, Jul 17, 2013 at 7:29 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > On Wed, 2013-07-17 at 19:22 -0400, KOSAKI Motohiro wrote:
> >> On Wed, Jul 17, 2013 at 5:45 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> >> > CONFIG_ARCH_MEMORY_PROBE enables /sys/devices/system/memory/probe
> >> > interface, which allows a given memory address to be hot-added as
> >> > follows. (See Documentation/memory-hotplug.txt for more detail.)
> >> >
> >> > # echo start_address_of_new_memory > /sys/devices/system/memory/probe
> >> >
> >> > This probe interface is required on powerpc. On x86, however, ACPI
> >> > notifies a memory hotplug event to the kernel, which performs its
> >> > hotplug operation as the result. Therefore, users should not be
> >> > required to use this interface on x86. This probe interface is also
> >> > error-prone that the kernel blindly adds a given memory address
> >> > without checking if the memory is present on the system; no probing
> >> > is done despite of its name. The kernel crashes when a user requests
> >> > to online a memory block that is not present on the system.
> >> >
> >> > This patch disables CONFIG_ARCH_MEMORY_PROBE by default on x86,
> >> > and clarifies it in Documentation/memory-hotplug.txt.
> >>
> >> Why don't you completely remove it? Who should use this strange interface?
> >
> > According to the comment below, this probe interface is used on powerpc.
> > So, we cannot remove it, but to disable it on x86.
> 
> I meant x86. Why can't we completely remove ARCH_MEMORY_PROBE section
> from x86 Kconfig?

Oh, I see what you meant.  I do not expect any need for end-users, but I
was not sure if someone working on the memory hotplug development might
use it for fake hot-add testing.  Yes, if you folks do not see any need,
I will remove it from x86 Kconfig.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
