Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2FCB88D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 22:05:38 -0500 (EST)
Message-ID: <4D5355D1.3050408@redhat.com>
Date: Thu, 10 Feb 2011 11:04:49 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH v2] Controlling kexec behaviour when hardware error
 happened.
References: <5C4C569E8A4B9B42A84A977CF070A35B2C1494DBE0@USINDEVS01.corp.hds.com> <m1bp2l2l31.fsf@fess.ebiederm.org>
In-Reply-To: <m1bp2l2l31.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Seiji Aguchi <seiji.aguchi@hds.com>, "hpa@zytor.com" <hpa@zytor.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "bp@alien8.de" <bp@alien8.de>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "gregkh@suse.de" <gregkh@suse.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Satoru Moriya <satoru.moriya@hds.com>

ao? 2011a1'02ae??10ae?JPY 01:07, Eric W. Biederman a??e??:
>
> Is there any reason we can't put logic to decided if we should write
> a crashdump in the crashdump userspace?
>

Doesn't this already provide a choice for the user to decide if he wants
a crashdump via sysctl?

Except some minor issues pointed by you and Greg, this patch looks fine
for me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
