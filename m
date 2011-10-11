Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C7E156B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 11:14:16 -0400 (EDT)
Date: Tue, 11 Oct 2011 17:14:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen
 before deferring
Message-ID: <20111011151412.GF23284@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com>
 <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com>
 <20111011063336.GA23284@tiehlicka.suse.cz>
 <4E9457BA.8060002@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E9457BA.8060002@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, rjw@sisk.pl, linux-mm@kvack.org, htejun@gmail.com

On Tue 11-10-11 10:50:34, KOSAKI Motohiro wrote:
> >> Looks ok to me.
> >> Michal, do you agree this patch?
> > 
> > The patch looks good but we still need other 2 patches
> > (http://comments.gmane.org/gmane.linux.kernel.mm/68578), right?
> > 
> > Anyway, I thought that we agreed on the other approach suggested by
> > Tejun (make frozen tasks oom killable without thawing). Even in that
> > case we want the first patch
> > (http://permalink.gmane.org/gmane.linux.kernel.mm/68576).
> 
> I'm sorry. I still don't catch up the above long thread. 

To sum up. There are 3 patches flying around at the moment.
http://permalink.gmane.org/gmane.linux.kernel.mm/68576
http://permalink.gmane.org/gmane.linux.kernel.mm/68577
http://permalink.gmane.org/gmane.linux.kernel.mm/68583

They are approaching the problem by thawing oom selected frozen task.

Tejun mentioned his work (sorry I do not have a link to patches) that
should enable direct killing frozen tasks. This would mean that we do
not need any special handling from the OOM code paths AFAIU. This would
be much better of course and I guess we can wait for them for 3.2.

Does this make sense?

> Could you please resend your final patch again? I'll review it.
> 
> Thank you.

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
