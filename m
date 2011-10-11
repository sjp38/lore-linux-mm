Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7D26B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 02:33:43 -0400 (EDT)
Date: Tue, 11 Oct 2011 08:33:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen
 before deferring
Message-ID: <20111011063336.GA23284@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com>
 <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

Hi,
sorry for the late reply but I was on vacation last week.

On Sat 08-10-11 03:23:15, KOSAKI Motohiro wrote:
> 2011/10/7 David Rientjes <rientjes@google.com>:
> > If a thread has been oom killed and is frozen, thaw it before returning
> > to the page allocator.  Otherwise, it can stay frozen indefinitely and
> > no memory will be freed.
> >
> > Reported-by: Michal Hocko <mhocko@suse.cz>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  v2: adds the missing header file include, the resend patch was based on a
> >     previous patch from Michal that is no longer needed if this is
> >     applied.
> 
> Looks ok to me.
> Michal, do you agree this patch?

The patch looks good but we still need other 2 patches
(http://comments.gmane.org/gmane.linux.kernel.mm/68578), right?

Anyway, I thought that we agreed on the other approach suggested by
Tejun (make frozen tasks oom killable without thawing). Even in that
case we want the first patch
(http://permalink.gmane.org/gmane.linux.kernel.mm/68576).
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
