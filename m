Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E067C62007F
	for <linux-mm@kvack.org>; Mon, 17 May 2010 05:40:01 -0400 (EDT)
Message-ID: <4BF10EE4.7020906@linux.intel.com>
Date: Mon, 17 May 2010 11:39:48 +0200
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC,5/7] NUMA hotplug emulator
References: <20100513115625.GF2169@shaohui> <20100507141142.GA8696@ucw.cz> <20100517033712.GA3075@shaohui>
In-Reply-To: <20100517033712.GA3075@shaohui>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>, lethal@linux-sh.org, Nathan Fontenot <nfont@austin.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Thomas Renninger <trenn@suse.de>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>, Alex Chiang <achiang@hp.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Shaohua Li <shaohua.li@intel.com>, Jean Delvare <khali@linux-fr.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-acpi@vger.kernel.org, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com, linux-hotplug@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> 	
> PowerPC supporting
> 	For ppc, it was added about half year ago by Nathan Fontenot, but x86 does not has such feature.
> Thanks for lethal to mention it, we already did some researching about it,  I will reply it in another
> thread.

Again the probe interface only covers part of the code, not ACPI for example.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
