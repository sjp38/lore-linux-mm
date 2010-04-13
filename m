Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE206B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:08:58 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id o3DF8lla024516
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:38:47 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3DF8lFq1974298
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:38:47 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3DF8kqX026800
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 01:08:46 +1000
Date: Tue, 13 Apr 2010 20:38:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: update documentation v5
Message-ID: <20100413150843.GI3994@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
 <20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com>
 <20100409100430.7409c7c4.randy.dunlap@oracle.com>
 <20100413134553.7e2c4d3d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100413135718.GA4493@redhat.com>
 <20100413140302.GB4493@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100413140302.GB4493@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Vivek Goyal <vgoyal@redhat.com> [2010-04-13 10:03:02]:

> On Tue, Apr 13, 2010 at 09:57:18AM -0400, Vivek Goyal wrote:
> > On Tue, Apr 13, 2010 at 01:45:53PM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> 
> Typed wrong email id last time and mail bounced. So here is another
> attempt.
> 
> > [..]
> > > -2. Locking
> > > +2.6 Locking
> > >  
> > > -The memory controller uses the following hierarchy
> > > +   lock_page_cgroup()/unlock_page_cgroup() should not be called under
> > > +   mapping->tree_lock.
> > >  
> > 
> > Because I never understood very well, I will ask. Why lock_page_cgroup()
> > should not be called under mapping->tree_lock?
> > 

The closest reference I can find to a conversation regarding this is

http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-05/msg05158.html

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
