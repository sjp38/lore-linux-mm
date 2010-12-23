Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CE8CD6B0092
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 19:30:30 -0500 (EST)
Date: Wed, 22 Dec 2010 16:29:35 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC][PATCH] Add a sysctl option controlling kexec when MCE
 occurred
Message-ID: <20101223002935.GA9811@suse.de>
References: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
Sender: owner-linux-mm@kvack.org
To: Seiji Aguchi <seiji.aguchi@hds.com>
Cc: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linuxfoundation.org" <akpm@linuxfoundation.org>, "eugeneteo@kernel.org" <eugeneteo@kernel.org>, "kees.cook@canonical.com" <kees.cook@canonical.com>, "drosenberg@vsecurity.com" <drosenberg@vsecurity.com>, "ying.huang@intel.com" <ying.huang@intel.com>, "len.brown@intel.com" <len.brown@intel.com>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "hadi@cyberus.ca" <hadi@cyberus.ca>, "hawk@comx.dk" <hawk@comx.dk>, "opurdila@ixiacom.com" <opurdila@ixiacom.com>, "hidave.darkstar@gmail.com" <hidave.darkstar@gmail.com>, "dzickus@redhat.com" <dzickus@redhat.com>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ext-andriy.shevchenko@nokia.com" <ext-andriy.shevchenko@nokia.com>, "tj@kernel.org" <tj@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Satoru Moriya <satoru.moriya@hds.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 22, 2010 at 06:35:40PM -0500, Seiji Aguchi wrote:
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -81,6 +81,9 @@
>  #include <linux/nmi.h>
>  #endif
>  
> +#ifdef CONFIG_X86_MCE
> +#include <asm/mce.h>
> +#endif

Please don't put ifdefs in .c files, you do that a lot for this option.
Just make it work on all platforms and then you will not need the
#ifdef.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
