Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id C5B376B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 04:38:46 -0500 (EST)
Date: Wed, 21 Dec 2011 01:41:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix.patch added
 to -mm tree
Message-Id: <20111221014138.45192a39.akpm@linux-foundation.org>
In-Reply-To: <20111221093547.GC27137@tiehlicka.suse.cz>
References: <20111220233037.47879100052@wpzn3.hot.corp.google.com>
	<20111221093547.GC27137@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, mszeredi@suse.cz, yinghan@google.com, linux-mm@kvack.org

On Wed, 21 Dec 2011 10:35:47 +0100 Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 20-12-11 15:30:36, Andrew Morton wrote:
> > 
> > The patch titled
> >      Subject: memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix
> > has been added to the -mm tree.  Its filename is
> >      memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix.patch
> > 
> > Before you just go and hit "reply", please:
> >    a) Consider who else should be cc'ed
> >    b) Prefer to cc a suitable mailing list as well
> >    c) Ideally: find the original patch on the mailing list and do a
> >       reply-to-all to that, adding suitable additional cc's
> > 
> > *** Remember to use Documentation/SubmitChecklist when testing your code ***
> > 
> > See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> > out what to do about this
> > 
> > The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> > 
> > ------------------------------------------------------
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix
> > 
> > ksm.c needs memcontrol.h, per Michal
> 
> Just for record. It really doesn't need it at the moment because it gets
> memcontrol.h via rmap.h resp. swap.h but I plan to remove memcontrol
> include from those two.
> I can do that in a separate patch if you prefer?

Sure.  It's generally bad to rely upon nested includes, especially one
which the outer header file included for its own purposes (which might
change).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
