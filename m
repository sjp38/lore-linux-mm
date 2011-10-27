Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8120E6B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 16:18:55 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p9RKIkvd011126
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 13:18:48 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by hpaq12.eem.corp.google.com with ESMTP id p9RK98sn019408
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 13:18:45 -0700
Received: by pzk1 with SMTP id 1so11441384pzk.9
        for <linux-mm@kvack.org>; Thu, 27 Oct 2011 13:18:44 -0700 (PDT)
Date: Thu, 27 Oct 2011 13:18:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
In-Reply-To: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
Message-ID: <alpine.DEB.2.00.1110271318220.7639@chino.kir.corp.google.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

On Thu, 27 Oct 2011, Dan Magenheimer wrote:

> Hi Linus --
> 
> Frontswap now has FOUR users: Two already merged in-tree (zcache
> and Xen) and two still in development but in public git trees
> (RAMster and KVM).  Frontswap is part 2 of 2 of the core kernel
> changes required to support transcendent memory; part 1 was cleancache
> which you merged at 3.0 (and which now has FIVE users).
> 
> Frontswap patches have been in linux-next since June 3 (with zero
> changes since Sep 22).  First posted to lkml in June 2009, frontswap 
> is now at version 11 and has incorporated feedback from a wide range
> of kernel developers.  For a good overview, see
>    http://lwn.net/Articles/454795.
> If further rationale is needed, please see the end of this email
> for more info.
> 
> SO... Please pull:
> 
> git://oss.oracle.com/git/djm/tmem.git #tmem
> 

Isn't this something that should go through the -mm tree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
