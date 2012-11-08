Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id B41FE6B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 17:18:59 -0500 (EST)
Date: Thu, 8 Nov 2012 14:18:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: Export vm_committed_as
Message-Id: <20121108141857.5a643a98.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1211081413350.20544@chino.kir.corp.google.com>
References: <1349654347-18337-1-git-send-email-kys@microsoft.com>
	<1349654386-18378-1-git-send-email-kys@microsoft.com>
	<20121008004358.GA12342@kroah.com>
	<426367E2313C2449837CD2DE46E7EAF930A1FB31@SN2PRD0310MB382.namprd03.prod.outlook.com>
	<20121008133539.GA15490@kroah.com>
	<20121009124755.ce1087b4.akpm@linux-foundation.org>
	<426367E2313C2449837CD2DE46E7EAF930DF7FBB@SN2PRD0310MB382.namprd03.prod.outlook.com>
	<20121105134456.f655b85a.akpm@linux-foundation.org>
	<426367E2313C2449837CD2DE46E7EAF930DFA7B8@SN2PRD0310MB382.namprd03.prod.outlook.com>
	<alpine.DEB.2.00.1211051418560.5296@chino.kir.corp.google.com>
	<426367E2313C2449837CD2DE46E7EAF930E0D0CC@CH1PRD0310MB381.namprd03.prod.outlook.com>
	<20121108140529.af7849c8.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1211081413350.20544@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KY Srinivasan <kys@microsoft.com>, Greg KH <gregkh@linuxfoundation.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "apw@canonical.com" <apw@canonical.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

On Thu, 8 Nov 2012 14:14:35 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 8 Nov 2012, Andrew Morton wrote:
> 
> > > > I don't think you should export the symbol itself to modules but rather a
> > > > helper function that returns s64 that just wraps
> > > > percpu_counter_read_positive() which your driver could use instead.
> > > > 
> > > > (And why percpu_counter_read_positive() returns a signed type is a
> > > > mystery.)
> > > 
> > > Yes, this makes sense. I just want to access (read) this metric. Andrew, if you are willing to
> > > take this patch, I could send one.
> > 
> > Sure.  I suppose that's better, although any module which modifies
> > committed_as would never pass review (rofl).
> > 
> 
> I was thinking of a function that all hypervisors can use (since xen also 
> uses it) that can be well documented and maintain the semantics that they 
> expect, whether that relines on vm_commited_as in the future or not.

Yes, it would be nice to have some central site where people can go to
understand what's happening here.

It's still unclear to me that committed_as is telling the
hypervisors precisely what they want to know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
