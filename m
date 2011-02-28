Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DF1C68D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 05:12:02 -0500 (EST)
Date: Mon, 28 Feb 2011 11:12:00 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM v4
Message-ID: <20110228101200.GF4648@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
 <1298485162.7236.4.camel@nimitz>
 <20110224134045.GA22122@tiehlicka.suse.cz>
 <20110225122522.8c4f1057.kamezawa.hiroyu@jp.fujitsu.com>
 <20110225095357.GA23241@tiehlicka.suse.cz>
 <20110228095347.7510b1d4.kamezawa.hiroyu@jp.fujitsu.com>
 <20110228091256.GA4648@tiehlicka.suse.cz>
 <20110228182322.a34cc1fd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110228095316.GC4648@tiehlicka.suse.cz>
 <20110228184821.f10dba19.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110228184821.f10dba19.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 28-02-11 18:48:21, KAMEZAWA Hiroyuki wrote:
> On Mon, 28 Feb 2011 10:53:16 +0100
> > From e7a897a42b526620eb4afada2d036e1c9ff9e62a Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Mon, 28 Feb 2011 10:43:12 +0100
> > Subject: [PATCH] page_cgroup array is never stored on reserved pages
> > 
> > KAMEZAWA Hiroyuki noted that free_pages_cgroup doesn't have to check for
> > PageReserved because we never store the array on reserved pages
> > (neither alloc_pages_exact nor vmalloc use those pages).
> > 
> > So we can replace the check by a BUG_ON.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Thank you.
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks!

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
