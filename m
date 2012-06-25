Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 1073C6B0321
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 05:17:00 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6216354dak.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 02:16:59 -0700 (PDT)
Date: Mon, 25 Jun 2012 02:16:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: replace some information in tasklist dump
In-Reply-To: <4FE81531.90500@gmail.com>
Message-ID: <alpine.DEB.2.00.1206250215510.24381@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206221444370.23486@chino.kir.corp.google.com> <CAHGf_=p4SS7qA_eRpBF0PawyUa8DpYncL0LS-=B4tHFaDUKV-w@mail.gmail.com> <alpine.DEB.2.00.1206221609220.15114@chino.kir.corp.google.com> <CAHGf_=q=6uWb4wpZxnZNGY=VohoaWrDJtiQk0Rn59unNSMTnyQ@mail.gmail.com>
 <alpine.DEB.2.00.1206221634230.18408@chino.kir.corp.google.com> <4FE50B81.5080603@gmail.com> <alpine.DEB.2.00.1206241340400.13297@chino.kir.corp.google.com> <4FE81531.90500@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, 25 Jun 2012, KOSAKI Motohiro wrote:

> > Your patch is factoring ptes into get_mm_rss() throughout the kernel, my 
> > patch is showing get_mm_rss() and nr_ptes in the oom killer tasklist dump 
> > since they are both (currently) factored in seperately.  They are two 
> > functionally different changes.
> 
> I said they should not showed separetly. That's all. Don't request talk the
> same repeat.
> 

I'm sorry, but I don't understand what you're trying to say.  If you have 
a patch to build upon in -mm (since my patch is already in it), feel free 
to post it with a changelog.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
