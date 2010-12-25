Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2B7CC6B008C
	for <linux-mm@kvack.org>; Sat, 25 Dec 2010 12:20:22 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
	<aab9953c699dace1ed94efd6505c7844.squirrel@www.firstfloor.org>
	<20101223091851.GC30055@liondog.tnic>
	<5C4C569E8A4B9B42A84A977CF070A35B2C132F6BB0@USINDEVS01.corp.hds.com>
	<m11v58xnyy.fsf@fess.ebiederm.org>
	<5C4C569E8A4B9B42A84A977CF070A35B2C132F6CFA@USINDEVS01.corp.hds.com>
Date: Sat, 25 Dec 2010 09:19:54 -0800
In-Reply-To: <5C4C569E8A4B9B42A84A977CF070A35B2C132F6CFA@USINDEVS01.corp.hds.com>
	(Seiji Aguchi's message of "Sat, 25 Dec 2010 09:56:50 -0500")
Message-ID: <m1oc89ixc5.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH] Add a sysctl option controlling kexec when MCE occurred
Sender: owner-linux-mm@kvack.org
To: Seiji Aguchi <seiji.aguchi@hds.com>
Cc: Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "akpm@linuxfoundation.org" <akpm@linuxfoundation.org>, "eugeneteo@kernel.org" <eugeneteo@kernel.org>, "kees.cook@canonical.com" <kees.cook@canonical.com>, "drosenberg@vsecurity.com" <drosenberg@vsecurity.com>, "ying.huang@intel.com" <ying.huang@intel.com>, "len.brown@intel.com" <len.brown@intel.com>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "davem@davemloft.net" <davem@davemloft.net>, "hadi@cyberus.ca" <hadi@cyberus.ca>, "hawk@comx.dk" <hawk@comx.dk>, "opurdila@ixiacom.com" <opurdila@ixiacom.com>, "hidave.darkstar@gmail.com" <hidave.darkstar@gmail.com>, "dzickus@redhat.com" <dzickus@redhat.com>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ext-andriy.shevchenko@nokia.com" <ext-andriy.shevchenko@nokia.com>, "tj@kernel.org" <tj@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Satoru Moriya <satoru.moriya@hds.com>
List-ID: <linux-mm.kvack.org>

Seiji Aguchi <seiji.aguchi@hds.com> writes:

> Hi,
>
> Thank you for giving your comments.
>
>>So what is the problem you are trying to avoid, and why can't we do
>>something in the kernels initialization path to avoid initializing
>>when there is a problem?
>
> Kdump gets a dump disk identifier based on information from memory.
>
> So, kdump may receive wrong identifier when it starts after MCE 
> occurred, because MCE is reported by memory, cache, and TLB errors
>
> In the worst case, kdump will overwrite user data if it recognizes a 
> disk saving user data as a dump disk.

Absurdly unlikely there is a sha256 checksum verified over the
kdump kernel before it starts booting.  If you have very broken
memory it is possible, but absurdly unlikely that the machine will
even boot if you are having enough uncorrectable memory errors
an hour to get past the sha256 checksum and then be corruppt.

> Kdump shouldn't write any data to disk when information from
> hardware is incredible because saving user data is always first 
> priority.

Which is what is already implemented.

It looks to me like you are jumping at shadows, and adding
complexity to the kernel with no gain, and significant cost.


Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
