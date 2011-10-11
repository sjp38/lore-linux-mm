Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 064426B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 19:36:42 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p9BNacNb015093
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:36:39 -0700
Received: from vcbfl17 (vcbfl17.prod.google.com [10.220.204.81])
	by wpaz37.hot.corp.google.com with ESMTP id p9BNYKNx007440
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:36:32 -0700
Received: by vcbfl17 with SMTP id fl17so12256vcb.7
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:36:32 -0700 (PDT)
Date: Tue, 11 Oct 2011 16:36:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen
 before deferring
In-Reply-To: <20111011063336.GA23284@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1110111633160.5236@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com> <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com> <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com> <20111011063336.GA23284@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

On Tue, 11 Oct 2011, Michal Hocko wrote:

> The patch looks good but we still need other 2 patches
> (http://comments.gmane.org/gmane.linux.kernel.mm/68578), right?
> 

For the lguest patch, Rusty is the maintainer and has already acked the 
patch, so I think it should be merged through him.  I don't see a need for 
the second patch since we'll now detect frozen oom killed tasks on retry 
and don't need to kill them directly when oom killed (it just adds 
additional, unnecessary code).

> Anyway, I thought that we agreed on the other approach suggested by
> Tejun (make frozen tasks oom killable without thawing). Even in that
> case we want the first patch
> (http://permalink.gmane.org/gmane.linux.kernel.mm/68576).

If that's possible, then we can just add Tejun to add a follow-up patch to 
remove the thaw directly in the oom killer.  I'm thinking that won't be 
possible for 3.2, though, so I don't know why we'd remove 
oom-thaw-threads-if-oom-killed-thread-is-frozen-before-deferring.patch 
from -mm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
