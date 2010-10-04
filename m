Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 236B96B0047
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 09:07:47 -0400 (EDT)
Date: Mon, 4 Oct 2010 08:07:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web
 servers
In-Reply-To: <20101004211112.E8B1.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010040805500.2502@router.home>
References: <20100927110049.6B31.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009270828510.7000@router.home> <20101004211112.E8B1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Oct 2010, KOSAKI Motohiro wrote:

> > The problem with zone reclaim mainly is created for large apps whose
> > working set is larger than the local node. The special settings are only
> > needing for those applications.
>
> In theory, yes. but please talk with userland developers. They always say
> "Our software work fine on *BSD, Solaris, Mac, etc etc. that's definitely
> linux problem". /me have no way to persuade them ;-)

Do those support NUMA? I would think not. You would have to switch on
interleave at the BIOS level (getting a hardware hack in place to get
rid of the NUMA effects) to make these OSes run right.

> This is one of option. but we don't need to create x86 arch specific
> RECLAIM_DISTANCE. Because practical high-end numa machine are either
> ia64(SGI, Fujitsu) or Power(IBM) and both platform already have arch
> specific definition. then changing RECLAIM_DISTANCE doesn't make any
> side effect on such platform. and if possible, x86 shouldn't have
> arch specific definition because almost minor arch don't have a lot of
> tester and its quality often depend on testing on x86.
>
> attached a patch below.

Looks good.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
