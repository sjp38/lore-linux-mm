Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 66DD46B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 04:38:33 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id n9T8cTmP030859
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 08:38:29 GMT
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by wpaz24.hot.corp.google.com with ESMTP id n9T8cQUb000561
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 01:38:26 -0700
Received: by pwj3 with SMTP id 3so1400497pwj.8
        for <linux-mm@kvack.org>; Thu, 29 Oct 2009 01:38:26 -0700 (PDT)
Date: Thu, 29 Oct 2009 01:38:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com>
 <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
 <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com> <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, KAMEZAWA Hiroyuki wrote:

> It's _not_ special to X.
> 
> Almost all applications which uses many dynamica libraries can be affected by this,
> total_vm. And, as I explained to Vedran, multi-threaded program like Java can easily
> increase total_vm without using many anon_rss.
> And it's the reason I hate overcommit_memory. size of VM doesn't tell anything.
> 

Right, because in Vedran's latest oom log it shows that Xorg is preferred 
more than any other thread other than the memory hogging test program with 
your patch than without.  I pointed out a clear distinction in the killing 
order using both total_vm and rss in that log and in my opinion killing 
Xorg as opposed to krunner would be undesireable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
