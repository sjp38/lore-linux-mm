Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C07EF6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 10:24:51 -0400 (EDT)
Message-ID: <4DE4FA2B.2050504@fnarfbargle.com>
Date: Tue, 31 May 2011 22:24:43 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com>
In-Reply-To: <20110531103808.GA6915@eferding.osrc.amd.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>

On 31/05/11 18:38, Borislav Petkov wrote:
> On Tue, May 31, 2011 at 05:26:10PM +0800, Brad Campbell wrote:
>> On 31/05/11 13:47, Borislav Petkov wrote:
>>> Looks like a KSM issue. Disabling CONFIG_KSM should at least stop your
>>> machine from oopsing.
>>>
>>> Adding linux-mm.
>>>
>>
>> I initially thought that, so the second panic was produced with KSM
>> disabled from boot.
>>
>> echo 0>  /sys/kernel/mm/ksm/run
>>
>> If you still think that compiling ksm out of the kernel will prevent
>> it then I'm willing to give it a go.
>
> Ok, from looking at the code, when KSM inits, it starts the ksm kernel
> thread and it looks like your oops comes from the function that is run
> in the kernel thread - ksm_scan_thread.
>
> So even if you disable it from sysfs, it runs at least once.
>

Just to confirm, I recompiled 2.6.38.7 without KSM enabled and I've been 
unable to reproduce the bug, so it looks like you were on the money.

I've moved back to 2.6.38.7 as 2.6.39 has a painful SCSI bug that panics 
about 75% of boots, and the reboot cycle required to get luck my way 
into a working kernel is just too much hassle.

It would appear that XP zero's its memory space on bootup, so there 
would be lots of pages to merge with a couple of relatively freshly 
booted XP machines running.

Regards,
Brad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
