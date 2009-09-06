Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3F6FF6B0088
	for <linux-mm@kvack.org>; Sun,  6 Sep 2009 19:38:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n86NcTPL016063
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 7 Sep 2009 08:38:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19BF145DE50
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 08:38:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 793F345DE4F
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 08:38:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C86151DB803A
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 08:38:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED5181DB803C
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 08:38:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()  sc->isolate_pages() return value.
In-Reply-To: <alpine.DEB.2.00.0909040856030.17650@kernelhack.brc.ubc.ca>
References: <alpine.DEB.2.00.0909032146130.10307@kernelhack.brc.ubc.ca> <alpine.DEB.2.00.0909040856030.17650@kernelhack.brc.ubc.ca>
Message-Id: <20090907083603.2C74.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Sep 2009 08:38:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >  [ Sending Preferences ]
> >       [X]  Do Not Send Flowed Text                                               
> >       [ ]  Downgrade Multipart to Text                                           
> >       [X]  Enable 8bit ESMTP Negotiation    (default)
> >       [ ]  Strip Whitespace Before Sending                                       
> >  
> > And Documentation/email-clients.txt have:
> > 
> > Config options:
> > - quell-flowed-text is needed for recent versions
> > - the "no-strip-whitespace-before-send" option is needed
> > 
> > Am I the one to blame? Should I uncheck the 'Do Not Send Flowed Text'? I 
> > am sorry if it is my fault.
> 
> Ah, I quoted the pine Config options, the alpine config options from 
> Documentation/email-clients.txt should be:
> 
> Config options:
> In the "Sending Preferences" section:
> 
> - "Do Not Send Flowed Text" must be enabled
> - "Strip Whitespace Before Sending" must be disabled

Can you please make email-clients.txt fixing patch too? :-)



> 
> and my alpine did follow the recommendations as above showed.
> 
> I used 'git send-email' to send out the original patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
