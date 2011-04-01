Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 11B818D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 13:32:01 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p31HVtwK012027
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 23:01:55 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31HVrZp4239466
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 23:01:54 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31HVsVM012335
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 23:01:54 +0530
Date: Fri, 1 Apr 2011 23:01:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
Message-ID: <20110401173145.GT2879@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
 <20110330163607.0984b831.akpm@linux-foundation.org>
 <20110331052703.GJ2879@balbir.in.ibm.com>
 <20110330223231.e1f149eb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110330223231.e1f149eb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

* Andrew Morton <akpm@linux-foundation.org> [2011-03-30 22:32:31]:

> On Thu, 31 Mar 2011 10:57:03 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Andrew Morton <akpm@linux-foundation.org> [2011-03-30 16:36:07]:
> > 
> > > On Wed, 30 Mar 2011 11:00:26 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > Data from the previous patchsets can be found at
> > > > https://lkml.org/lkml/2010/11/30/79
> > > 
> > > It would be nice if the data for the current patchset was present in
> > > the current patchset's changelog!
> > >
> > 
> > Sure, since there were no major changes, I put in a URL. The main
> > change was the documentation update. 
> 
> Well some poor schmuck has to copy and paste the data into the
> changelog so it's still there in five years time.  It's better to carry
> this info around in the patch's own metedata, and to maintain
> and update it.
>

Agreed, will do. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
