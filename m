Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4E3486B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 14:40:39 -0400 (EDT)
Received: by mail-da0-f46.google.com with SMTP id y19so1795025dan.33
        for <linux-mm@kvack.org>; Thu, 21 Mar 2013 11:40:38 -0700 (PDT)
Date: Thu, 21 Mar 2013 11:40:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
In-Reply-To: <20130321105516.GC18484@gmail.com>
Message-ID: <alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com>
References: <20130318155619.GA18828@sgi.com> <20130321105516.GC18484@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Russ Anderson <rja@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com

On Thu, 21 Mar 2013, Ingo Molnar wrote:

> > Index: linux/mm/page_alloc.c
> > ===================================================================
> > --- linux.orig/mm/page_alloc.c	2013-03-18 10:52:11.510988843 -0500
> > +++ linux/mm/page_alloc.c	2013-03-18 10:52:14.214931348 -0500
> > @@ -4161,10 +4161,19 @@ int __meminit __early_pfn_to_nid(unsigne
> >  {
> >  	unsigned long start_pfn, end_pfn;
> >  	int i, nid;
> > +	static unsigned long last_start_pfn, last_end_pfn;
> > +	static int last_nid;
> 
> Please move these globals out of function local scope, to make it more 
> apparent that they are not on-stack. I only noticed it in the second pass.
> 

The way they're currently defined places these in meminit.data as 
appropriate; if they are moved out, please make sure to annotate their 
definitions with __meminitdata.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
