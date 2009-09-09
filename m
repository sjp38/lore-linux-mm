Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E688F6B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 08:03:47 -0400 (EDT)
Date: Wed, 9 Sep 2009 14:04:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list() sc->isolate_pages() return value.
Message-ID: <20090909120407.GA3598@cmpxchg.org>
References: <alpine.DEB.2.00.0909032146130.10307@kernelhack.brc.ubc.ca> <alpine.DEB.2.00.0909040856030.17650@kernelhack.brc.ubc.ca> <20090907083603.2C74.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0909081106490.24907@kernelhack.brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0909081106490.24907@kernelhack.brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 08, 2009 at 11:32:45AM -0700, Vincent Li wrote:
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
> recommendation. I am not sure if my alpine is the faulty email client. Is 
> there still something missing with alpine? 

It seems it was Minchan's mail
<28c262360909031837j4e1a9214if6070d02cb4fde04@mail.gmail.com> that
replaced ascii spacing with some utf8 spacing characters.

It is arguable whether this conversion was sensible but a bit sad
that, apparently, by mid 2009 still not every email client is able to
cope. :/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
