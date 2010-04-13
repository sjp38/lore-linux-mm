Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D21456B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:16:50 -0400 (EDT)
Date: Tue, 13 Apr 2010 11:16:45 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] memcg: update documentation v5
Message-ID: <20100413151645.GC4493@redhat.com>
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com> <20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com> <20100409100430.7409c7c4.randy.dunlap@oracle.com> <20100413134553.7e2c4d3d.kamezawa.hiroyu@jp.fujitsu.com> <20100413135718.GA4493@redhat.com> <20100413140302.GB4493@redhat.com> <20100413150843.GI3994@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413150843.GI3994@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 08:38:43PM +0530, Balbir Singh wrote:
> * Vivek Goyal <vgoyal@redhat.com> [2010-04-13 10:03:02]:
> 
> > On Tue, Apr 13, 2010 at 09:57:18AM -0400, Vivek Goyal wrote:
> > > On Tue, Apr 13, 2010 at 01:45:53PM +0900, KAMEZAWA Hiroyuki wrote:
> > > 
> > 
> > Typed wrong email id last time and mail bounced. So here is another
> > attempt.
> > 
> > > [..]
> > > > -2. Locking
> > > > +2.6 Locking
> > > >  
> > > > -The memory controller uses the following hierarchy
> > > > +   lock_page_cgroup()/unlock_page_cgroup() should not be called under
> > > > +   mapping->tree_lock.
> > > >  
> > > 
> > > Because I never understood very well, I will ask. Why lock_page_cgroup()
> > > should not be called under mapping->tree_lock?
> > > 
> 
> The closest reference I can find to a conversation regarding this is
> 
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-05/msg05158.html
> 

Thanks Balbir. So basically idea is that page_cgroup_lock() does not
disable interrupts hence can be interrupted. So don't do
lock_page_cgroup() in interrupt context at all otherwise it can lead to
various kind of deadlock scenarios.

One of those scenarios is lock_page_cgroup() under mapping->tree_lock.

That helps. Thanks

Vivek

> -- 
> 	Three Cheers,
> 	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
