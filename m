Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE056B003B
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 02:58:48 -0400 (EDT)
Date: Wed, 12 Oct 2011 08:58:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen
 before deferring
Message-ID: <20111012065845.GD31570@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com>
 <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com>
 <20111011063336.GA23284@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1110111633160.5236@chino.kir.corp.google.com>
 <20111012065026.GA31570@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111012065026.GA31570@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

On Wed 12-10-11 08:50:26, Michal Hocko wrote:
> On Tue 11-10-11 16:36:28, David Rientjes wrote:
> > On Tue, 11 Oct 2011, Michal Hocko wrote:
> > 
> > > The patch looks good but we still need other 2 patches
> > > (http://comments.gmane.org/gmane.linux.kernel.mm/68578), right?
> > > 
> > 
> > For the lguest patch, Rusty is the maintainer and has already acked the 
> > patch, so I think it should be merged through him.  I don't see a need for 
> > the second patch since we'll now detect frozen oom killed tasks on retry 
> > and don't need to kill them directly when oom killed (it just adds 
> > additional, unnecessary code).
> 
> OK, my understanding was that we need both patches, but you are right,
> the later one should be sufficient.

Ahh and I forgot to add:
Acked-by: Michal Hocko <mhocko@suse.cz>

If it matters.

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
