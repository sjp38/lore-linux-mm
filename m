Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE556B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 15:07:17 -0400 (EDT)
Date: Tue, 11 Oct 2011 21:07:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen
 before deferring
Message-ID: <20111011190709.GA28605@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com>
 <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com>
 <20111011063336.GA23284@tiehlicka.suse.cz>
 <4E9457BA.8060002@jp.fujitsu.com>
 <20111011151412.GF23284@tiehlicka.suse.cz>
 <4E94676F.2030302@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E94676F.2030302@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, htejun@gmail.com
Cc: rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, rjw@sisk.pl, linux-mm@kvack.org

On Tue 11-10-11 11:57:35, KOSAKI Motohiro wrote:
> > To sum up. There are 3 patches flying around at the moment.
> > http://permalink.gmane.org/gmane.linux.kernel.mm/68576
> > http://permalink.gmane.org/gmane.linux.kernel.mm/68577
> > http://permalink.gmane.org/gmane.linux.kernel.mm/68583
> > 
> > They are approaching the problem by thawing oom selected frozen task.
> > 
> > Tejun mentioned his work (sorry I do not have a link to patches) that
> > should enable direct killing frozen tasks. This would mean that we do
> > not need any special handling from the OOM code paths AFAIU. This would
> > be much better of course and I guess we can wait for them for 3.2.
> > 
> > Does this make sense?
> 
> I don't find any bad in the idea. So, I have two questions.
> 
>  o Who are writing such patch now?

Tejun, could you send a link to those patches, please?

>  o Should we drop current drientjes patch?

This pretty much depends on when Tejun is able to provide the mentioned
patches. If we want to keep David's patch we want also the other
patches, don't we?

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
