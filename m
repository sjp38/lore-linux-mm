Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B8FF76B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:17:55 -0400 (EDT)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n9S6Hl91007585
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 06:17:47 GMT
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by spaceape10.eur.corp.google.com with ESMTP id n9S6HiE6015020
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 23:17:44 -0700
Received: by pwj8 with SMTP id 8so643364pwj.23
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 23:17:43 -0700 (PDT)
Date: Tue, 27 Oct 2009 23:17:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com>
 <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
 <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, KAMEZAWA Hiroyuki wrote:

> All kernel engineers know "than expected or not" can be never known to the kernel.
> So, oom_adj workaround is used now. (by some special users.)
> OOM Killer itself is also a workaround, too.
> "No kill" is the best thing but we know there are tend to be memory-leaker on bad
> systems and all systems in this world are not perfect.
> 

Right, and historically that has been addressed by considering total_vm 
and adjusting it with oom_adj so that we can identify memory leaking tasks 
through user-defined criteria.

> Yes, some more trustable values other than vmsize/rss/time are appriciated.
> I wonder recent memory consumption speed can be an another key value.
> 

Sounds very logical.

> Anyway, current bahavior of "killing X" is a bad thing.
> We need some fixes.
> 

You can easily protect X with OOM_DISABLE, as you know.  I don't think we 
need any X-specific heuristics added to the kernel, it looks like the 
special cases have already polluted badness() enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
