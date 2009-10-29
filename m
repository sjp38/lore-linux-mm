Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D1AE36B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 04:35:53 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n9T8Zngp011302
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 08:35:49 GMT
Received: from pzk13 (pzk13.prod.google.com [10.243.19.141])
	by spaceape8.eur.corp.google.com with ESMTP id n9T8ZkYm016233
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 01:35:47 -0700
Received: by pzk13 with SMTP id 13so1079003pzk.25
        for <linux-mm@kvack.org>; Thu, 29 Oct 2009 01:35:46 -0700 (PDT)
Date: Thu, 29 Oct 2009 01:35:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <4AE9068B.7030504@gmail.com>
Message-ID: <alpine.DEB.2.00.0910290132320.11476@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com>
 <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <4AE846E8.1070303@gmail.com> <alpine.DEB.2.00.0910281307370.23279@chino.kir.corp.google.com>
 <4AE9068B.7030504@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009, Vedran Furac wrote:

> > We would know if you posted the data.
> 
> I need to find some free time to destroy a session on a computer which I
> use for work. You could easily test it yourself also as this doesn't
> happen only to me.
> 
> Anyways, here it is... this time it started with ntpd:
> 
> http://pastebin.com/f3f9674a0
> 

That oom log shows 12 ooms but no tasks actually appear to be getting 
killed (there're no "Killed process 1234 (task)" found).  Do you have any 
idea why?

Anyway, as I posted in response to KAMEZAWA-san's patch, the change to 
get_mm_rss(mm) prefers Xorg more than the current implementation.

>From your log at the link above:

total_vm
669624 test
195695 krunner
187342 krusader
168881 plasma-desktop
130562 ktorrent
127081 knotify4
125881 icedove-bin
123036 akregator

rss
668738 test
42191 Xorg
30761 firefox-bin
13331 icedove-bin
10234 ktorrent
9263 akregator
8864 plasma-desktop
7532 krunner

Can you explain why Xorg is preferred as a baseline to kill rather than 
krunner in your example?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
