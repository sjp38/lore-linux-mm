Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA7D6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 19:46:41 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p9BNkcL6003373
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:46:39 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq13.eem.corp.google.com with ESMTP id p9BNihcb017918
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:46:37 -0700
Received: by qyk7 with SMTP id 7so257345qyk.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:46:37 -0700 (PDT)
Date: Tue, 11 Oct 2011 16:46:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen
 before deferring
In-Reply-To: <20111011233914.GC6281@google.com>
Message-ID: <alpine.DEB.2.00.1110111645090.5236@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com> <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com> <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com> <20111011063336.GA23284@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1110111633160.5236@chino.kir.corp.google.com> <20111011233914.GC6281@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org

On Tue, 11 Oct 2011, Tejun Heo wrote:

> > If that's possible, then we can just add Tejun to add a follow-up patch to 
> > remove the thaw directly in the oom killer.  I'm thinking that won't be 
> > possible for 3.2, though, so I don't know why we'd remove 
> > oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring.patch 
> > from -mm?
> 
> Yeah, it's a bit unclear.  All (or at least most) patches which were
> necessary for this patch was queued in Rafael's tree before korg went
> belly up and then we both lost track of the tree and I need to
> regenerate the tree and ask Rafael to pull again.

Eek, what a pain.

> I think the merge
> window is already too close, so please go ahead with the acked fix.
> Let's clean it up during the next devel cycle.
> 

Ok, sounds good.  When frozen oom killed threads can always move down the 
exit path, then we can just remember to remove the thaw_process() from the 
oom killer.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
