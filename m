Subject: Re: [PATCH 5/7] mlocked-pages: add event counting with statistics
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <2f11576a0807301340s1289f93al80202135261c7f6b@mail.gmail.com>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	 <20080730200649.24272.58778.sendpatchset@lts-notebook>
	 <2f11576a0807301340s1289f93al80202135261c7f6b@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 30 Jul 2008 17:00:45 -0400
Message-Id: <1217451645.7676.19.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-31 at 05:40 +0900, KOSAKI Motohiro wrote:
> > +               } else {
> > +                       /*
> > +                        * We lost the race.  let try_to_unmap() deal
> > +                        * with it.  At least we get the page state and
> > +                        * mlock stats right.  However, page is still on
> > +                        * the noreclaim list.  We'll fix that up when
> > +                        * the page is eventually freed or we scan the
> > +                        * noreclaim list.
> 
>                                unevictable list?

Yeah.  I missed that one.  Time for a global search, I guess.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
