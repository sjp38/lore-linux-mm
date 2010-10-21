Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3F29F6B0087
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 20:14:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9L0EfG0001883
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 Oct 2010 09:14:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EF30B45DE55
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:14:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D0E9C45DE4E
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:14:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B7FBF1DB803A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:14:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 75CA21DB8038
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:14:40 +0900 (JST)
Date: Thu, 21 Oct 2010 09:08:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V2] nommu: add anonymous page memcg accounting
Message-Id: <20101021090847.b4e23dde.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287578957.2603.34.camel@iscandar.digidescorp.com>
References: <1287491654-4005-1-git-send-email-steve@digidescorp.com>
	<20101019154819.GC15844@balbir.in.ibm.com>
	<1287512657.2500.31.camel@iscandar.digidescorp.com>
	<20101020091746.f0cc5dc2.kamezawa.hiroyu@jp.fujitsu.com>
	<1287578957.2603.34.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: steve@digidescorp.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Oct 2010 07:49:17 -0500
"Steven J. Magnani" <steve@digidescorp.com> wrote:

> On Wed, 2010-10-20 at 09:17 +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 19 Oct 2010 13:24:17 -0500
> > "Steven J. Magnani" <steve@digidescorp.com> wrote:
> > 
> > > On Tue, 2010-10-19 at 21:18 +0530, Balbir Singh wrote:
> > > > * Steven J. Magnani <steve@digidescorp.com> [2010-10-19 07:34:14]:
> > > > > +
> > > > > +At the present time, only anonymous pages are included in NOMMU memory cgroup
> > > > > +accounting.
> > > > 
> > > > What is the reason for tracking just anonymous memory?
> > > 
> > > Tracking more than that is beyond my current scope, and perhaps of
> > > limited benefit under an assumption that NOMMU systems don't usually
> > > work with large files. The limitations of the implementation are
> > > documented, so hopefully anyone who needs more functionality will know
> > > that they need to implement it.
> > > 
> > 
> > What happens at reaching limit ? memory can be reclaimed ?
> 
> I'm not quite sure what you're asking. In my usage, the OOM-killer gets
> invoked and the 'runaway' dosfsck process gets terminated; at that point
> all its memory is freed. 
> 

Hmm. then, most of memcg codes are of no use for NOMMU.
I myself can't maintain NOMMU kernel. So, please test every -rc1 when
this patch merged. OK ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
