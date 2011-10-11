Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 575276B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 19:41:39 -0400 (EDT)
Received: by pzk4 with SMTP id 4so283807pzk.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:41:36 -0700 (PDT)
Date: Tue, 11 Oct 2011 16:41:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch resend] oom: thaw threads if oom killed thread is frozen
 before deferring
Message-Id: <20111011164132.16e504a8.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1110111628200.5236@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
	<20111011191603.GA12751@redhat.com>
	<alpine.DEB.2.00.1110111628200.5236@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Tue, 11 Oct 2011 16:30:26 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 11 Oct 2011, Oleg Nesterov wrote:
> 
> > David. Could you also resend you patches which remove the (imho really
> > annoying) mm->oom_disable_count? Feel free to add my ack or reviewed-by.
> > 
> 
> As far as I know (I can't confirm because userweb.kernel.org is still 
> down), oom-remove-oom_disable_count.patch is still in the -mm tree.  It 
> was merged September 2 so I believe it's 3.2 material.

yup.  It's in linux-next too.

> Andrew, please add Oleg's reviewed-by to that patch (in addition to the 
> reported-by which already exists) if it's still merged.

Done, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
