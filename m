Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E3A846B00B5
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 01:09:06 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id oA4593th006676
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 22:09:04 -0700
Received: from pvc22 (pvc22.prod.google.com [10.241.209.150])
	by hpaq3.eem.corp.google.com with ESMTP id oA4591oC030709
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 22:09:02 -0700
Received: by pvc22 with SMTP id 22so612404pvc.41
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 22:09:01 -0700 (PDT)
Date: Wed, 3 Nov 2010 22:08:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Re:[PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
In-Reply-To: <1288845730.2102.11.camel@myhost>
Message-ID: <alpine.DEB.2.00.1011032203470.10054@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain> <1288827804.2725.0.camel@localhost.localdomain> <alpine.DEB.2.00.1011031646110.7830@chino.kir.corp.google.com> <AANLkTimjfmLzr_9+Sf4gk0xGkFjffQ1VcCnwmCXA88R8@mail.gmail.com> <1288834737.2124.11.camel@myhost>
 <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com> <1288836733.2124.18.camel@myhost> <alpine.DEB.2.00.1011031952110.28251@chino.kir.corp.google.com> <1288845730.2102.11.camel@myhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Nov 2010, Figo.zhang wrote:

> CAP_SYS_RESOURCE == 1 means without resource limits just like a
> superuser,
> CAP_SYS_RESOURCE == 0 means hold resource limits, like normal user,
> right?
> 

Yes.

> a new lower oom_score_adj will protect the process, right?
> 

Yes.

> Tasks without CAP_SYS_RESOURCE, means that it is not a superuser, why
> user canot protect it by oom_score_adj?
> 

Because, as I said, it would be trivial for a user program to deplete all 
memory (either intentionally or unintentioally) and cause every other task 
on the system to be oom killed as a result.  That's an undesired result of 
a blatently obvious DoS.

> like i want to protect my program such as gnome-terminal which is
> without CAP_SYS_RESOURCE (have resource limits), 
> 
> [figo@myhost ~]$ ps -ax | grep gnome-ter
> Warning: bad ps syntax, perhaps a bogus '-'? See
> http://procps.sf.net/faq.html
>  2280 ?        Sl     0:01 gnome-terminal
>  8839 pts/0    S+     0:00 grep gnome-ter
> [figo@myhost ~]$ cat /proc/2280/oom_adj 
> 3
> [figo@myhost ~]$ echo -17 >  /proc/2280/oom_adj 
> bash: echo: write error: Permission denied
> [figo@myhost ~]$ 
> 
> so, i canot protect my program.
> 

If this is your system, you can either give yourself CAP_SYS_RESOURCE or 
do it through the superuser.  This isn't exactly new, it's been the case 
for the past four years.

I'm still struggling to find out the problem that you're trying to address 
with your various patches, perhaps because you haven't said what it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
