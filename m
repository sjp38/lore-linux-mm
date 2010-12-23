Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 62F096B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 02:43:43 -0500 (EST)
Message-ID: <aab9953c699dace1ed94efd6505c7844.squirrel@www.firstfloor.org>
In-Reply-To: 
 <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
References: 
    <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
Date: Thu, 23 Dec 2010 08:43:39 +0100
Subject: Re: [RFC][PATCH] Add a sysctl option controlling kexec when MCE
 occurred
From: "Andi Kleen" <andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Seiji Aguchi <seiji.aguchi@hds.com>
Cc: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linuxfoundation.org" <akpm@linuxfoundation.org>, "eugeneteo@kernel.org" <eugeneteo@kernel.org>, "kees.cook@canonical.com" <kees.cook@canonical.com>, "drosenberg@vsecurity.com" <drosenberg@vsecurity.com>, "ying.huang@intel.com" <ying.huang@intel.com>, "len.brown@intel.com" <len.brown@intel.com>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "davem@davemloft.net" <davem@davemloft.net>, "hadi@cyberus.ca" <hadi@cyberus.ca>, "hawk@comx.dk" <hawk@comx.dk>, "opurdila@ixiacom.com" <opurdila@ixiacom.com>, "hidave.darkstar@gmail.com" <hidave.darkstar@gmail.com>, "dzickus@redhat.com" <dzickus@redhat.com>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ext-andriy.shevchenko@nokia.com" <ext-andriy.shevchenko@nokia.com>, "tj@kernel.org" <tj@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Satoru Moriya <satoru.moriya@hds.com>
List-ID: <linux-mm.kvack.org>



>   - Accessing to memory and dumping it to disks.

A better solution for this is

http://git.kernel.org/?p=linux/kernel/git/ak/linux-mce-2.6.git;a=commitdiff;h=fe61906edce9e70d02481a77a617ba1397573dce
and
http://git.kernel.org/?p=linux/kernel/git/ak/linux-mce-2.6.git;a=commit;h=cb58f049ae6709ddbab71be199390dc6852018cd

I'm not a big friend of sysctls for things like this -- either the behaviour
makes sense and should be default or not.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
