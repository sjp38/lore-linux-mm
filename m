Date: Mon, 3 Mar 2008 18:58:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.24] mm: BadRAM support for broken memory
Message-Id: <20080303185825.9634f762.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200803031835.03082.nickpiggin@yahoo.com.au>
References: <2f11576a0803020901n715fda8esbfc0172f5a15ae3c@mail.gmail.com>
	<200803031632.47888.nickpiggin@yahoo.com.au>
	<20080303161025.1E7E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<200803031835.03082.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, Rick van Rein <rick@vanrein.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2008 18:35:02 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Monday 03 March 2008 18:14, KOSAKI Motohiro wrote:
> > > > some architecture use PG_reserved for treat bad memory.
> > > > Why do you want introduce new page flag?
> > > > for show_mem() improvement?
> > >
> > > I'd like to get rid of PG_reserved at some point. So I'd
> > > rather not overload it with more meanings ;)
> >
> > really?
> >
> > as far as I know, IA64 already use PG_reserved for bad memory.
> > please see arch/ia64/kernel/mcs_drv.c#mca_page_isolate.
> >
> > Doesn't it works on ia64 if your patch introduce?
> 
> It doesn't really need to use PG_reserved there, no. It could
> use PG_bad for that instead.
> 
Hmm, it seems that it's necessary to rewrite ia64/mca code after PG_bad
patch is merged.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
