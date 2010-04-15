Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 58F7B6B01FD
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 11:50:27 -0400 (EDT)
Date: Thu, 15 Apr 2010 08:48:38 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] memcg: update documentation v8
Message-Id: <20100415084838.afe18a68.randy.dunlap@oracle.com>
In-Reply-To: <20100415093406.d7331ae2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
	<20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com>
	<20100409100430.7409c7c4.randy.dunlap@oracle.com>
	<20100413134553.7e2c4d3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100413060405.GF3994@balbir.in.ibm.com>
	<20100413152048.55408738.kamezawa.hiroyu@jp.fujitsu.com>
	<20100413064855.GH3994@balbir.in.ibm.com>
	<20100413155841.ca6bc425.kamezawa.hiroyu@jp.fujitsu.com>
	<4BC493B4.2040709@oracle.com>
	<20100414102221.2c540a0d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414111146.c2907cd7.randy.dunlap@oracle.com>
	<20100415093406.d7331ae2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Apr 2010 09:34:06 +0900 KAMEZAWA Hiroyuki wrote:

> On Wed, 14 Apr 2010 11:11:46 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
> > >  	#echo 1 > memory.oom_control
> > 
> > 
> > BTW:  it would be a lot easier [for reviewing] if you could freeze (or merge) this version
> > and then apply fixes on top of it with a different (and shorter) patch.
> > 
> > Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
> > 
> Thank you very much for your patient review. It has been very helpful.
> 
> Here is fixed one.

Please ship it!

Thanks.

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
