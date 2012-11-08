Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 3D58D6B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 16:55:16 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so1485476dad.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 13:55:15 -0800 (PST)
Date: Thu, 8 Nov 2012 13:55:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 1/2] mm: Export vm_committed_as
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF930DFC381@SN2PRD0310MB382.namprd03.prod.outlook.com>
Message-ID: <alpine.DEB.2.00.1211081354550.19214@chino.kir.corp.google.com>
References: <1349654347-18337-1-git-send-email-kys@microsoft.com> <1349654386-18378-1-git-send-email-kys@microsoft.com> <20121008004358.GA12342@kroah.com> <426367E2313C2449837CD2DE46E7EAF930A1FB31@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20121008133539.GA15490@kroah.com> <20121009124755.ce1087b4.akpm@linux-foundation.org> <426367E2313C2449837CD2DE46E7EAF930DF7FBB@SN2PRD0310MB382.namprd03.prod.outlook.com> <20121105134456.f655b85a.akpm@linux-foundation.org>
 <426367E2313C2449837CD2DE46E7EAF930DFA7B8@SN2PRD0310MB382.namprd03.prod.outlook.com> <20121106090539.GB21167@dhcp22.suse.cz> <426367E2313C2449837CD2DE46E7EAF930DFC381@SN2PRD0310MB382.namprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "apw@canonical.com" <apw@canonical.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

On Thu, 8 Nov 2012, KY Srinivasan wrote:

> > Thanks Michal. Yes, the kernel driver reports this metric to the host.
> > Andrew, let me know how I should proceed here.
> 
> Ping.
> 

Could you respond to my email in this thread?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
