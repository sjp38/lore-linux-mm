Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D53AF6B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 10:03:06 -0400 (EDT)
Date: Tue, 13 Apr 2010 10:03:02 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] memcg: update documentation v5
Message-ID: <20100413140302.GB4493@redhat.com>
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com> <20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com> <20100409100430.7409c7c4.randy.dunlap@oracle.com> <20100413134553.7e2c4d3d.kamezawa.hiroyu@jp.fujitsu.com> <20100413135718.GA4493@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413135718.GA4493@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 09:57:18AM -0400, Vivek Goyal wrote:
> On Tue, Apr 13, 2010 at 01:45:53PM +0900, KAMEZAWA Hiroyuki wrote:
> 

Typed wrong email id last time and mail bounced. So here is another
attempt.

> [..]
> > -2. Locking
> > +2.6 Locking
> >  
> > -The memory controller uses the following hierarchy
> > +   lock_page_cgroup()/unlock_page_cgroup() should not be called under
> > +   mapping->tree_lock.
> >  
> 
> Because I never understood very well, I will ask. Why lock_page_cgroup()
> should not be called under mapping->tree_lock?
> 
> Thanks
> Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
