Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E729C6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 19:30:34 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p9BNUVDJ020126
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:30:31 -0700
Received: from qadc14 (qadc14.prod.google.com [10.224.32.142])
	by hpaq12.eem.corp.google.com with ESMTP id p9BNTvRl013055
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:30:30 -0700
Received: by qadc14 with SMTP id c14so336792qad.10
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:30:30 -0700 (PDT)
Date: Tue, 11 Oct 2011 16:30:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch resend] oom: thaw threads if oom killed thread is frozen
 before deferring
In-Reply-To: <20111011191603.GA12751@redhat.com>
Message-ID: <alpine.DEB.2.00.1110111628200.5236@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com> <20111011191603.GA12751@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Tue, 11 Oct 2011, Oleg Nesterov wrote:

> David. Could you also resend you patches which remove the (imho really
> annoying) mm->oom_disable_count? Feel free to add my ack or reviewed-by.
> 

As far as I know (I can't confirm because userweb.kernel.org is still 
down), oom-remove-oom_disable_count.patch is still in the -mm tree.  It 
was merged September 2 so I believe it's 3.2 material.

Andrew, please add Oleg's reviewed-by to that patch (in addition to the 
reported-by which already exists) if it's still merged.  Otherwise, please 
let me know and I'll resend it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
