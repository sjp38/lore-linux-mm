Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 690096B0044
	for <linux-mm@kvack.org>; Sun, 12 Aug 2012 05:31:15 -0400 (EDT)
Date: Sun, 12 Aug 2012 11:31:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] hugetlb: correct page offset index for sharing pmd
Message-ID: <20120812093110.GB18057@dhcp22.suse.cz>
References: <20120810094825.GA1440@dhcp22.suse.cz>
 <CAJd=RBDA3pLYDpryxafx6dLoy7Fk8PmY-EFkXCkuJTB2ywfsjA@mail.gmail.com>
 <20120810122730.GA1425@dhcp22.suse.cz>
 <CAJd=RBAvCd-QcyN9N4xWEiLeVqRypzCzbADvD1qTziRVCHjd4Q@mail.gmail.com>
 <20120810125102.GB1425@dhcp22.suse.cz>
 <CAJd=RBB8Yuk1FEQxTUbEEeD96oqnO26VojetuDgRo=JxOfnadw@mail.gmail.com>
 <20120810131643.GC1425@dhcp22.suse.cz>
 <CAJd=RBDtnF6eoTmDu4HOBGfHnWnxNsXEzArR51+-XhzFCwOmOQ@mail.gmail.com>
 <20120810134811.GD1425@dhcp22.suse.cz>
 <CAJd=RBDUJXOHKbes0KE1aQ7tJCYBr04+=-bCbs8xT9wJ-CtrTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBDUJXOHKbes0KE1aQ7tJCYBr04+=-bCbs8xT9wJ-CtrTw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>

On Sun 12-08-12 12:08:21, Hillf Danton wrote:
> On Fri, Aug 10, 2012 at 9:48 PM, Michal Hocko <mhocko@suse.cz> wrote:
> 
> > It's been compile tested because it only restores the previous code with
> > a simple and obvious bug fix.
> 
> It helps more if you elaborate on such a simple and obvious bug and
> enrich your change log accordingly?

Hmmm, to be honest I really don't care much about this change. It is just
that your previous patch (0c176d5) made the code more confusing and this
aims at fixing that.

But anyway. I will post this to Andrew unless somebody has any
objections.
---
