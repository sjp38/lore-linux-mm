Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id F2E8F90011E
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:23:18 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p4GLNGNe025260
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:23:16 -0700
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by hpaq1.eem.corp.google.com with ESMTP id p4GLMB5X030524
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:23:14 -0700
Received: by pzk27 with SMTP id 27so3009944pzk.13
        for <linux-mm@kvack.org>; Mon, 16 May 2011 14:23:14 -0700 (PDT)
Date: Mon, 16 May 2011 14:23:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for current->comm
 references
In-Reply-To: <op.vve2a6hp3l0zgt@mnazarewicz-glaptop>
Message-ID: <alpine.DEB.2.00.1105161422490.4353@chino.kir.corp.google.com>
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org> <1305241371-25276-4-git-send-email-john.stultz@linaro.org> <4DCCD0C3.9090908@gmail.com> <op.vve2a6hp3l0zgt@mnazarewicz-glaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: John Stultz <john.stultz@linaro.org>, Jiri Slaby <jirislaby@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, 13 May 2011, Michal Nazarewicz wrote:

> On Fri, 13 May 2011 08:33:39 +0200, Jiri Slaby wrote:
> > This should be something like \b(current|task|tsk|t)->comm\b to catch
> > also non-current comm accesses...
> 
> Or \b(?:current|task|tsk|t)\s*->\s*comm\b.
> 

Add 'p' to the mix :)

$ grep -r "struct task_struct \*p[; ]" * | wc -l
119

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
