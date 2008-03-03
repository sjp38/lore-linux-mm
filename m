Received: by rv-out-0910.google.com with SMTP id f1so4314748rvb.26
        for <linux-mm@kvack.org>; Sun, 02 Mar 2008 19:06:54 -0800 (PST)
Message-ID: <44c63dc40803021906j6102b0aq6982f46cba52f476@mail.gmail.com>
Date: Mon, 3 Mar 2008 12:06:54 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: Re: [patch 12/21] No Reclaim LRU Infrastructure
In-Reply-To: <44c63dc40803021904n5de681datba400e08079c152d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080228192908.126720629@redhat.com>
	 <20080228192929.031646681@redhat.com>
	 <44c63dc40802282058h67f7597bvb614575f06c62e2c@mail.gmail.com>
	 <1204296534.5311.8.camel@localhost>
	 <44c63dc40803021904n5de681datba400e08079c152d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, I sended HTML format, so fail to send linux-kernel@vger.kernel.org
I will resend in TEXT/PLAIN format.

On Mon, Mar 3, 2008 at 12:04 PM, minchan Kim <barrioskmc@gmail.com> wrote:
> One more thing.
>
> zoneinfo_show_print fail to show right information.
> That's why 'enum zone_stat_item' and 'vmstat_text' index didn't matched.
> This is a problem about CONFIG_NORECLAIM, too.
>
>
>
>
>
> On Fri, Feb 29, 2008 at 11:48 PM, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
>
> >
> >
> >
> > On Fri, 2008-02-29 at 13:58 +0900, minchan Kim wrote:
> > >
> > >         +#ifdef CONFIG_NORECLAIM
> > >         +static inline void lru_cache_add_noreclaim(struct page *page)
> > >         +{
> > >         +       __lru_cache_add(page, LRU_NORECLAIM);
> > >         +}
> > >         +#else
> > >         +static inline void lru_cache_add_noreclaim(struct page *page)
> > >         +{
> > >         +       BUG("Noreclaim not configured, but page added
> > >         anyway?!");
> > >         +}
> > >         +#endif
> > >         +
> > >
> > > BUG() can't take a argument.
> >
> > Right.  I don't have a clue how that got there :-(.
> >
> > Thanks,
> > Lee
> >
> >
>
>
>
> --
> Thanks,
> barrios



-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
