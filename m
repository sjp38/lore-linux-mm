Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id CA1836B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 07:24:50 -0500 (EST)
Date: Tue, 28 Feb 2012 13:24:43 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: + memcg-remove-pcg_file_mapped.patch added to -mm tree
Message-ID: <20120228122443.GC1702@cmpxchg.org>
References: <20120217214600.28F87A01B8@akpm.mtv.corp.google.com>
 <20120220090935.1bd379b1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120220090935.1bd379b1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, gthelen@google.com, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, yinghan@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hillf Danton <dhillf@gmail.com>

On Mon, Feb 20, 2012 at 09:09:35AM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 17 Feb 2012 13:46:00 -0800
> akpm@linux-foundation.org wrote:
> 
> > 
> > The patch titled
> >      Subject: memcg: remove PCG_FILE_MAPPED
> > has been added to the -mm tree.  Its filename is
> >      memcg-remove-pcg_file_mapped.patch
> > 
> > Before you just go and hit "reply", please:
> >    a) Consider who else should be cc'ed
> >    b) Prefer to cc a suitable mailing list as well
> >    c) Ideally: find the original patch on the mailing list and do a
> >       reply-to-all to that, adding suitable additional cc's
> > 
> > *** Remember to use Documentation/SubmitChecklist when testing your code ***
> > 
> > The -mm tree is included into linux-next and is updated
> > there every 3-4 working days
> > 
> > ------------------------------------------------------
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Subject: memcg: remove PCG_FILE_MAPPED
> > 
> > With the new lock scheme for updating memcg's page stat, we don't need a
> > flag PCG_FILE_MAPPED which was duplicated information of page_mapped().
> > 
> 
> Johannes and Hillf pointed out this is required.
> Thank you!.
> 
> ==
> >From eed3550a81bc53a3d084a295e56654a18455103f Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 20 Feb 2012 09:19:44 +0900
> Subject: [PATCH] memcg: fix remove PCG_FILE_MAPPED
> 
> At move_acount(), accounting information nr_file_mapped per memcg is moved
> from old cgroup to new one.
> The patch  memcg-remove-pcg_file_mapped.patch chesk the condition by
> 
> 	if (page_mapped(page))
> 
> But we want to count only FILE_MAPPED. Then, this should be
> 
> 	if (!PageAnon(page) && page_mapped(page))
> 
> This handles following cases.
>   - anon  + mapped   => false
>   - anon  + unmapped => false (swap cache)
>   - shmem + mapped   => true
>   - shmem + unmapped => false (swap cache)
>   - file  + mapped   => true
>   - file  + unmapped => false
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

With that one folded in,

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

to the original patch 'memcg: remove PCG_FILE_MAPPED'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
