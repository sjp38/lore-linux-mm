Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A5356B004D
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 23:09:23 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1A49KWI026452
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 10 Feb 2010 13:09:20 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDD7F45DE52
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 13:09:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBBB645DE50
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 13:09:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E12A1DB803E
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 13:09:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 574201DB803C
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 13:09:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
In-Reply-To: <20100210035052.GH3290@balbir.in.ibm.com>
References: <20100210093140.12D9.A69D9226@jp.fujitsu.com> <20100210035052.GH3290@balbir.in.ibm.com>
Message-Id: <20100210130706.4D15.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Feb 2010 13:09:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Chris Friesen <cfriesen@nortel.com>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-02-10 09:32:07]:
> 
> > > Hi,
> > > 
> > > I'm hoping you can help me out.  I'm on a 2.6.27 x86 system and I'm
> > > seeing the "inactive" field in /proc/meminfo slowly growing over time to
> > > the point where eventually the oom-killer kicks in and starts killing
> > > things.  The growth is not evident in any other field in /proc/meminfo.
> > > 
> > > I'm trying to figure out where the memory is going, and what it's being
> > > used for.
> > > 
> > > As I've found, the fields in /proc/meminfo don't add up...in particular,
> > > active+inactive is quite a bit larger than
> > > buffers+cached+dirty+anonpages+mapped+pagetables+vmallocused.  Initially
> > > the difference is about 156MB, but after about 13 hrs the difference is
> > > 240MB.
> > > 
> > > How can I track down where this is going?  Can you suggest any
> > > instrumentation that I can add?
> > > 
> > > I'm reasonably capable, but I'm getting seriously confused trying to
> > > sort out the memory subsystem.  Some pointers would be appreciated.
> > 
> > can you please post your /proc/meminfo?
> 
> Do you have swap enabled? Can you help with the OOM killed dmesg log?
> Does the situation get better after OOM killing. /proc/meminfo as
> Kosaki suggested would be important as well. 

Indeed.

Chris, 2.6.27 is a bit old. plese test it on latest kernel. and please don't use
any proprietary drivers.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
