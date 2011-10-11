Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 424BE6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 19:39:22 -0400 (EDT)
Received: by gya6 with SMTP id 6so156884gya.14
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:39:19 -0700 (PDT)
Date: Tue, 11 Oct 2011 16:39:14 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen
 before deferring
Message-ID: <20111011233914.GC6281@google.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com>
 <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com>
 <20111011063336.GA23284@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1110111633160.5236@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110111633160.5236@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org

Hello,

On Tue, Oct 11, 2011 at 04:36:28PM -0700, David Rientjes wrote:
> On Tue, 11 Oct 2011, Michal Hocko wrote:
> 
> > The patch looks good but we still need other 2 patches
> > (http://comments.gmane.org/gmane.linux.kernel.mm/68578), right?
> > 
> 
> For the lguest patch, Rusty is the maintainer and has already acked the 
> patch, so I think it should be merged through him.  I don't see a need for 
> the second patch since we'll now detect frozen oom killed tasks on retry 
> and don't need to kill them directly when oom killed (it just adds 
> additional, unnecessary code).
> 
> > Anyway, I thought that we agreed on the other approach suggested by
> > Tejun (make frozen tasks oom killable without thawing). Even in that
> > case we want the first patch
> > (http://permalink.gmane.org/gmane.linux.kernel.mm/68576).
> 
> If that's possible, then we can just add Tejun to add a follow-up patch to 
> remove the thaw directly in the oom killer.  I'm thinking that won't be 
> possible for 3.2, though, so I don't know why we'd remove 
> oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring.patch 
> from -mm?

Yeah, it's a bit unclear.  All (or at least most) patches which were
necessary for this patch was queued in Rafael's tree before korg went
belly up and then we both lost track of the tree and I need to
regenerate the tree and ask Rafael to pull again.  I think the merge
window is already too close, so please go ahead with the acked fix.
Let's clean it up during the next devel cycle.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
