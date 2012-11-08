Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 159E26B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 17:14:39 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so2561653pbb.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 14:14:38 -0800 (PST)
Date: Thu, 8 Nov 2012 14:14:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: Export vm_committed_as
In-Reply-To: <20121108140529.af7849c8.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1211081413350.20544@chino.kir.corp.google.com>
References: <1349654347-18337-1-git-send-email-kys@microsoft.com> <1349654386-18378-1-git-send-email-kys@microsoft.com> <20121008004358.GA12342@kroah.com> <426367E2313C2449837CD2DE46E7EAF930A1FB31@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20121008133539.GA15490@kroah.com> <20121009124755.ce1087b4.akpm@linux-foundation.org> <426367E2313C2449837CD2DE46E7EAF930DF7FBB@SN2PRD0310MB382.namprd03.prod.outlook.com> <20121105134456.f655b85a.akpm@linux-foundation.org>
 <426367E2313C2449837CD2DE46E7EAF930DFA7B8@SN2PRD0310MB382.namprd03.prod.outlook.com> <alpine.DEB.2.00.1211051418560.5296@chino.kir.corp.google.com> <426367E2313C2449837CD2DE46E7EAF930E0D0CC@CH1PRD0310MB381.namprd03.prod.outlook.com>
 <20121108140529.af7849c8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KY Srinivasan <kys@microsoft.com>, Greg KH <gregkh@linuxfoundation.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "apw@canonical.com" <apw@canonical.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

On Thu, 8 Nov 2012, Andrew Morton wrote:

> > > I don't think you should export the symbol itself to modules but rather a
> > > helper function that returns s64 that just wraps
> > > percpu_counter_read_positive() which your driver could use instead.
> > > 
> > > (And why percpu_counter_read_positive() returns a signed type is a
> > > mystery.)
> > 
> > Yes, this makes sense. I just want to access (read) this metric. Andrew, if you are willing to
> > take this patch, I could send one.
> 
> Sure.  I suppose that's better, although any module which modifies
> committed_as would never pass review (rofl).
> 

I was thinking of a function that all hypervisors can use (since xen also 
uses it) that can be well documented and maintain the semantics that they 
expect, whether that relines on vm_commited_as in the future or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
