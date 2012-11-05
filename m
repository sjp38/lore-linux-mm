Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 80F466B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 17:33:15 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4661613pad.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 14:33:14 -0800 (PST)
Date: Mon, 5 Nov 2012 14:33:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 1/2] mm: Export vm_committed_as
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF930DFA7B8@SN2PRD0310MB382.namprd03.prod.outlook.com>
Message-ID: <alpine.DEB.2.00.1211051418560.5296@chino.kir.corp.google.com>
References: <1349654347-18337-1-git-send-email-kys@microsoft.com> <1349654386-18378-1-git-send-email-kys@microsoft.com> <20121008004358.GA12342@kroah.com> <426367E2313C2449837CD2DE46E7EAF930A1FB31@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20121008133539.GA15490@kroah.com> <20121009124755.ce1087b4.akpm@linux-foundation.org> <426367E2313C2449837CD2DE46E7EAF930DF7FBB@SN2PRD0310MB382.namprd03.prod.outlook.com> <20121105134456.f655b85a.akpm@linux-foundation.org>
 <426367E2313C2449837CD2DE46E7EAF930DFA7B8@SN2PRD0310MB382.namprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "apw@canonical.com" <apw@canonical.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

On Mon, 5 Nov 2012, KY Srinivasan wrote:

> The Hyper-V host has a policy engine for managing available physical memory across
> competing virtual machines. This policy decision is based on a number of parameters
> including the memory pressure reported by the guest. Currently, the pressure calculation is
> based on the memory commitment made by the guest. From what I can tell, the ratio of
> currently allocated physical memory to the current memory commitment made by the guest
> (vm_committed_as) is used as one of the parameters in making the memory balancing decision on
> the host. This is what Windows guests report to the host. So, I need some measure of memory
> commitments made by the Linux guest. This is the reason I want export vm_committed_as. 
> 

I don't think you should export the symbol itself to modules but rather a 
helper function that returns s64 that just wraps 
percpu_counter_read_positive() which your driver could use instead.

(And why percpu_counter_read_positive() returns a signed type is a 
mystery.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
