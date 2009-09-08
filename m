Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A43B96B0085
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 14:33:38 -0400 (EDT)
Date: Tue, 8 Sep 2009 11:32:45 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
In-Reply-To: <20090907083603.2C74.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0909081106490.24907@kernelhack.brc.ubc.ca>
References: <alpine.DEB.2.00.0909032146130.10307@kernelhack.brc.ubc.ca> <alpine.DEB.2.00.0909040856030.17650@kernelhack.brc.ubc.ca> <20090907083603.2C74.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Sep 2009, KOSAKI Motohiro wrote:

> > >  [ Sending Preferences ]
> > >       [X]  Do Not Send Flowed Text                                               
> > >       [ ]  Downgrade Multipart to Text                                           
> > >       [X]  Enable 8bit ESMTP Negotiation    (default)
> > >       [ ]  Strip Whitespace Before Sending                                       
> > >  
> > > And Documentation/email-clients.txt have:
> > > 
> > > Config options:
> > > - quell-flowed-text is needed for recent versions
> > > - the "no-strip-whitespace-before-send" option is needed
> > > 
> > > Am I the one to blame? Should I uncheck the 'Do Not Send Flowed Text'? I 
> > > am sorry if it is my fault.
> > 
> > Ah, I quoted the pine Config options, the alpine config options from 
> > Documentation/email-clients.txt should be:
> > 
> > Config options:
> > In the "Sending Preferences" section:
> > 
> > - "Do Not Send Flowed Text" must be enabled
> > - "Strip Whitespace Before Sending" must be disabled
> 
> Can you please make email-clients.txt fixing patch too? :-)

Sorry my poor written English make you confused.:-). The two config 
options for alpine are already in email-clients.txt and I followed the existing config options 
recommendation. I am not sure if my alpine is the faulty email client. Is 
there still something missing with alpine? 

> 
> 
> > 
> > and my alpine did follow the recommendations as above showed.
> > 
> > I used 'git send-email' to send out the original patch.
> 
> 
> 
> 

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
