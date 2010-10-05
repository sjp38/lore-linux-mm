Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AC7866B007E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 01:32:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o955WT76028697
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 5 Oct 2010 14:32:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF55F45DE7A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:32:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 92A7145DE6E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:32:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4420E1DB803B
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:32:28 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF8661DB8041
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:32:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web servers
In-Reply-To: <alpine.DEB.2.00.1010040805500.2502@router.home>
References: <20101004211112.E8B1.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010040805500.2502@router.home>
Message-Id: <20101005142527.28DB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  5 Oct 2010 14:32:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 4 Oct 2010, KOSAKI Motohiro wrote:
> 
> > > The problem with zone reclaim mainly is created for large apps whose
> > > working set is larger than the local node. The special settings are only
> > > needing for those applications.
> >
> > In theory, yes. but please talk with userland developers. They always say
> > "Our software work fine on *BSD, Solaris, Mac, etc etc. that's definitely
> > linux problem". /me have no way to persuade them ;-)
> 
> Do those support NUMA? I would think not. You would have to switch on
> interleave at the BIOS level (getting a hardware hack in place to get
> rid of the NUMA effects) to make these OSes run right.

Sure. It wouldn't. Many opensource userland developers don't like
using out of posix API. In the other hand, many proprietery developers
don't hesitate it. I don't know reason.
Also, I'm not sure evey Corei7 Motherboard have BIOS level numa interleaving.
Are you sure? generically, commodity component vendor don't like to equipe 
additonal firmware feature. It's not zero cost. I think this solusion only fit
server vendor (e.g. IBM, HP, Fujitsu). but dunnno. Myself and fujitsu haven't hit 
this issue. I don't know _every_ motherboard equipement in the world.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
