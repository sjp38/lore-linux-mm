Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD438D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 11:51:54 -0500 (EST)
Date: Wed, 9 Feb 2011 08:51:23 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC][PATCH v2] Controlling kexec behaviour when hardware
 error happened.
Message-ID: <20110209165123.GA30346@suse.de>
References: <5C4C569E8A4B9B42A84A977CF070A35B2C1494DBE0@USINDEVS01.corp.hds.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5C4C569E8A4B9B42A84A977CF070A35B2C1494DBE0@USINDEVS01.corp.hds.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seiji Aguchi <seiji.aguchi@hds.com>
Cc: "hpa@zytor.com" <hpa@zytor.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "bp@alien8.de" <bp@alien8.de>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, "amwang@redhat.com" <amwang@redhat.com>, Satoru Moriya <satoru.moriya@hds.com>

On Wed, Feb 09, 2011 at 11:35:43AM -0500, Seiji Aguchi wrote:
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -153,6 +153,7 @@ enum
>  	KERN_MAX_LOCK_DEPTH=74, /* int: rtmutex's maximum lock depth */
>  	KERN_NMI_WATCHDOG=75, /* int: enable/disable nmi watchdog */
>  	KERN_PANIC_ON_NMI=76, /* int: whether we will panic on an unrecovered */
> +	KERN_KEXEC_ON_HWERR=77, /* int: bevaviour of kexec for hardware error 
> +*/

Odd trailing comment on the next line.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
