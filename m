Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id E129B6B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 16:48:05 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so6672806pdj.35
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 13:48:05 -0700 (PDT)
Date: Mon, 9 Sep 2013 13:48:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: The scan_unevictable_pages sysctl/node-interface has been
 disabled
In-Reply-To: <20130903230611.GE1412@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1309091347020.19959@chino.kir.corp.google.com>
References: <CANkm-FgvMU-e0uxSvdV1+T5CbEdTCrj=2LVYnVEOALF8myoMxw@mail.gmail.com> <20130903230611.GE1412@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander R <aleromex@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Tue, 3 Sep 2013, Johannes Weiner wrote:

> On Tue, Sep 03, 2013 at 11:53:24PM +0400, Alexander R wrote:
> > [2000266.127978] nr_pdflush_threads exported in /proc is scheduled for
> > removal
> > [2000266.128022] sysctl: The scan_unevictable_pages sysctl/node-interface
> > has been disabled for lack of a legitimate use case.  If you have one,
> > please send an email to linux-mm@kvack.org.
> 
> Well, do you have one? :-)
> 
> Or is this just leftover in a script somewhere?
> 

Should we be printing current's parent's comm here too?  "sysctl" isn't 
very helpful to identify the source.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
