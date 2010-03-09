Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB2276B00DA
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 18:16:09 -0500 (EST)
Date: Tue, 9 Mar 2010 15:15:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] memcg : share event counter rather than duplicate
 v2
Message-Id: <20100309151514.56b8396d.akpm@linux-foundation.org>
In-Reply-To: <20100215091906.c08a6ed7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180508.eb58a4d1.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180952.28b2f6c5.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212204810.704f90f0.d-nishimura@mtf.biglobe.ne.jp>
	<20100215091906.c08a6ed7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010 09:19:06 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > >  /**
> > > @@ -1760,6 +1768,11 @@ static int mem_cgroup_move_account(struc
> > >  		ret = 0;
> > >  	}
> > >  	unlock_page_cgroup(pc);
> > > +	/*
> > > +	 * check events
> > > +	 */
> > > +	memcg_check_events(to, pc->page);
> > > +	memcg_check_events(from, pc->page);
> > >  	return ret;
> > >  }
> > >  
> > Strictly speaking, "if (!ret)" would be needed(it's not a big deal, though).
> > 
> Hmm. ok. I'll check.

I'll assume that your checking resulted in happiness with the existing
patch ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
