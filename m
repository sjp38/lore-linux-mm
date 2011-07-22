Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 90A356B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 06:23:38 -0400 (EDT)
Date: Fri, 22 Jul 2011 12:23:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg: do not try to drain per-cpu caches without
 pages
Message-ID: <20110722102331.GG4004@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
 <113c4affc2f0938b7b22d43c88d2b0a623de9a6b.1311241300.git.mhocko@suse.cz>
 <20110721191250.1c945740.kamezawa.hiroyu@jp.fujitsu.com>
 <20110721113606.GA27855@tiehlicka.suse.cz>
 <20110722084413.9dd4b880.kamezawa.hiroyu@jp.fujitsu.com>
 <20110722091936.GB4004@tiehlicka.suse.cz>
 <20110722182822.a99a2676.kamezawa.hiroyu@jp.fujitsu.com>
 <20110722095815.GF4004@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110722095815.GF4004@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Fri 22-07-11 11:58:15, Michal Hocko wrote:
> On Fri 22-07-11 18:28:22, KAMEZAWA Hiroyuki wrote:
> > On Fri, 22 Jul 2011 11:19:36 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Fri 22-07-11 08:44:13, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 21 Jul 2011 13:36:06 +0200
> > > > By 2 methods
> > > > 
> > > >  - just check nr_pages. 
> > > 
> > > Not sure I understand which nr_pages you mean. The one that comes from
> > > the charging path or stock->nr_pages?
> > > If you mean the first one then we do not have in the reclaim path where
> > > we call drain_all_stock_async.
> > > 
> > 
> > stock->nr_pages.
> > 
> > > >  - drain "local stock" without calling schedule_work(). It's fast.
> > > 
> > > but there is nothing to be drained locally in the paths where we call
> > > drain_all_stock_async... Or do you mean that drain_all_stock shouldn't
> > > use work queue at all?
> > 
> > I mean calling schedule_work against local cpu is just waste of time.
> > Then, drain it directly and move local cpu's stock->nr_pages to res_counter.
> 
> got it. Thanks for clarification. Will repost the updated version.
---
