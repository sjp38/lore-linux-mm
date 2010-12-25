Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 960566B0095
	for <linux-mm@kvack.org>; Sat, 25 Dec 2010 13:36:42 -0500 (EST)
Message-ID: <4D1638DE.1080005@zytor.com>
Date: Sat, 25 Dec 2010 10:33:02 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Add a sysctl option controlling kexec when MCE occurred
References: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>	<aab9953c699dace1ed94efd6505c7844.squirrel@www.firstfloor.org>	<20101223091851.GC30055@liondog.tnic>	<5C4C569E8A4B9B42A84A977CF070A35B2C132F6BB0@USINDEVS01.corp.hds.com>	<m11v58xnyy.fsf@fess.ebiederm.org>	<5C4C569E8A4B9B42A84A977CF070A35B2C132F6CFA@USINDEVS01.corp.hds.com> <m1oc89ixc5.fsf@fess.ebiederm.org>
In-Reply-To: <m1oc89ixc5.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Seiji Aguchi <seiji.aguchi@hds.com>, Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "akpm@linuxfoundation.org" <akpm@linuxfoundation.org>, "eugeneteo@kernel.org" <eugeneteo@kernel.org>, "kees.cook@canonical.com" <kees.cook@canonical.com>, "drosenberg@vsecurity.com" <drosenberg@vsecurity.com>, "ying.huang@intel.com" <ying.huang@intel.com>, "len.brown@intel.com" <len.brown@intel.com>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "davem@davemloft.net" <davem@davemloft.net>, "hadi@cyberus.ca" <hadi@cyberus.ca>, "hawk@comx.dk" <hawk@comx.dk>, "opurdila@ixiacom.com" <opurdila@ixiacom.com>, "hidave.darkstar@gmail.com" <hidave.darkstar@gmail.com>, "dzickus@redhat.com" <dzickus@redhat.com>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ext-andriy.shevchenko@nokia.com" <ext-andriy.shevchenko@nokia.com>, "tj@kernel.org" <tj@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Satoru Moriya <satoru.moriya@hds.com>
List-ID: <linux-mm.kvack.org>

On 12/25/2010 09:19 AM, Eric W. Biederman wrote:
>>
>> So, kdump may receive wrong identifier when it starts after MCE 
>> occurred, because MCE is reported by memory, cache, and TLB errors
>>
>> In the worst case, kdump will overwrite user data if it recognizes a 
>> disk saving user data as a dump disk.
> 
> Absurdly unlikely there is a sha256 checksum verified over the
> kdump kernel before it starts booting.  If you have very broken
> memory it is possible, but absurdly unlikely that the machine will
> even boot if you are having enough uncorrectable memory errors
> an hour to get past the sha256 checksum and then be corruppt.
> 

That wouldn't be the likely scenario (passing a sha256 checksum with the
wrong data due to a random event will never happen for all the computers
on Earth before the Sun destroys the planet).  However, in a
failing-memory scenario, the much more likely scenario is that kdump
starts up, verifies the signature, and *then* has corruption causing it
to write to the wrong disk or whatnot.  This is inherent in any scheme
that allows writing to hard media after a failure (as opposed to, say,
dumping to the network.)

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
