Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C9DB26B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 04:16:05 -0500 (EST)
Date: Thu, 26 Jan 2012 10:16:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from
 pc->flags
Message-ID: <20120126091602.GC13421@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
 <20120117164605.GB22142@tiehlicka.suse.cz>
 <20120118091226.b46e0f6e.kamezawa.hiroyu@jp.fujitsu.com>
 <20120118104703.GA31112@tiehlicka.suse.cz>
 <20120119085309.616cadb4.kamezawa.hiroyu@jp.fujitsu.com>
 <CALWz4ixAT411PZMwngh17V8VZEDGbMNNzbWFwbpC5M-JO+TVOQ@mail.gmail.com>
 <20120124084335.GE26289@tiehlicka.suse.cz>
 <CALWz4iy0ajriTk7V0xL1+W7rDFS+-M5w4OdPjasMGUTH=ZLgrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iy0ajriTk7V0xL1+W7rDFS+-M5w4OdPjasMGUTH=ZLgrw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Wed 25-01-12 15:07:47, Ying Han wrote:
> On Tue, Jan 24, 2012 at 12:43 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Mon 23-01-12 14:05:33, Ying Han wrote:
[...]
> >> Just want to make sure I understand it, even we make the lock
> >> per-memcg, there is still a false sharing of pc within one memcg.
> >
> > Yes that is true. I have missed that we might fault in several pages at
> > once but this would happen only during task move, right? And that is not
> > a hot path anyway. Or?
> 
> I was thinking of page-statistics update which is hot path. If the
> moving task and non-moving task share the same per-memcg lock, any
> page-statistic update from the non-moving task will be blocked? Sorry
> If i missed something here :)

OK, I got your point, finally. I guess there is a plan to reduce the
effect by array of locks.

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
