Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 08DB46B02E9
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 16:43:30 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5479217dak.14
        for <linux-mm@kvack.org>; Sun, 24 Jun 2012 13:43:30 -0700 (PDT)
Date: Sun, 24 Jun 2012 13:43:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: replace some information in tasklist dump
In-Reply-To: <4FE50B81.5080603@gmail.com>
Message-ID: <alpine.DEB.2.00.1206241340400.13297@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206221444370.23486@chino.kir.corp.google.com> <CAHGf_=p4SS7qA_eRpBF0PawyUa8DpYncL0LS-=B4tHFaDUKV-w@mail.gmail.com> <alpine.DEB.2.00.1206221609220.15114@chino.kir.corp.google.com> <CAHGf_=q=6uWb4wpZxnZNGY=VohoaWrDJtiQk0Rn59unNSMTnyQ@mail.gmail.com>
 <alpine.DEB.2.00.1206221634230.18408@chino.kir.corp.google.com> <4FE50B81.5080603@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Fri, 22 Jun 2012, KOSAKI Motohiro wrote:

> >> No worth to make fragile ABI. Do you have any benefit?
> >>
> > 
> > Yes, because this is exactly where we would discover something like a 
> > mm->nr_ptes accounting issue since it would result in an oom kill and we'd 
> > notice the mismatch between nr_ptes and rss in the tasklist dump.
> 
> Below patch is better, then. tasklist dump should show brief summary and
> final killed process output should show most detail info. And, now all of
> get_mm_rss() callsite got consistent.
> 

No, it's not.

Your patch is factoring ptes into get_mm_rss() throughout the kernel, my 
patch is showing get_mm_rss() and nr_ptes in the oom killer tasklist dump 
since they are both (currently) factored in seperately.  They are two 
functionally different changes.

If you want to factor ptes into get_mm_rss() and make that change 
throughout the kernel, then you should patch linux-next which includes my 
oom patch, write an actual changelog for why ptes should now be included 
in get_mm_rss() -- which I'll nack because it significantly changes 
/proc/pid/stat output for applications between kernel versions that we 
depend very heavily on -- and propose it seperately.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
