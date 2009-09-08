Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ECFF16B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 19:47:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n88NlRFv017382
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 9 Sep 2009 08:47:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 636BE45DE7B
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 08:47:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E7C445DE6F
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 08:47:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 042381DB8046
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 08:47:27 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 702A01DB8040
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 08:47:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()  sc->isolate_pages() return value.
In-Reply-To: <alpine.DEB.2.00.0909081106490.24907@kernelhack.brc.ubc.ca>
References: <20090907083603.2C74.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0909081106490.24907@kernelhack.brc.ubc.ca>
Message-Id: <20090909084626.0CD3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  9 Sep 2009 08:47:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 7 Sep 2009, KOSAKI Motohiro wrote:
> 
> > > >  [ Sending Preferences ]
> > > >       [X]  Do Not Send Flowed Text                                               
> > > >       [ ]  Downgrade Multipart to Text                                           
> > > >       [X]  Enable 8bit ESMTP Negotiation    (default)
> > > >       [ ]  Strip Whitespace Before Sending                                       
> > > >  
> > > > And Documentation/email-clients.txt have:
> > > > 
> > > > Config options:
> > > > - quell-flowed-text is needed for recent versions
> > > > - the "no-strip-whitespace-before-send" option is needed
> > > > 
> > > > Am I the one to blame? Should I uncheck the 'Do Not Send Flowed Text'? I 
> > > > am sorry if it is my fault.
> > > 
> > > Ah, I quoted the pine Config options, the alpine config options from 
> > > Documentation/email-clients.txt should be:
> > > 
> > > Config options:
> > > In the "Sending Preferences" section:
> > > 
> > > - "Do Not Send Flowed Text" must be enabled
> > > - "Strip Whitespace Before Sending" must be disabled
> > 
> > Can you please make email-clients.txt fixing patch too? :-)
> 
> Sorry my poor written English make you confused.:-). The two config 
> options for alpine are already in email-clients.txt and I followed the existing config options 
> recommendation. 

I see. sorry my misunderstood.
thanks :)

> I am not sure if my alpine is the faulty email client. Is 
> there still something missing with alpine? 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
