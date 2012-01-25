Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 2472E6B005C
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 02:17:27 -0500 (EST)
Date: Wed, 25 Jan 2012 08:17:16 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcg: fix over reclaiming mem cgroup
Message-ID: <20120125071715.GA7694@cmpxchg.org>
References: <CAJd=RBAbFd=MFZZyCKN-Si-Zt=C6dKVUaG-C7s5VKoTWfY00nA@mail.gmail.com>
 <20120123130221.GA15113@tiehlicka.suse.cz>
 <CALWz4izWYb=_svn=UJ1C--pWXv59H2ahn6EJEnTpJv-dT6WGsw@mail.gmail.com>
 <CAJd=RBAuDABE7u1wyc+45ZGoVos5PnxMe6P=ET-CHf-LChTpgw@mail.gmail.com>
 <20120124082352.GA26289@tiehlicka.suse.cz>
 <CAJd=RBDj5mtWJG0Byi=97Kuu6LnkwdndDO-AUpeYSCTBEy0P5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBDj5mtWJG0Byi=97Kuu6LnkwdndDO-AUpeYSCTBEy0P5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 25, 2012 at 09:55:01AM +0800, Hillf Danton wrote:
> On Tue, Jan 24, 2012 at 4:23 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > Barriered?
> >
> pushed out for 3.3-rc2 last night?

New features are only merged during the merge window (between 3.2 and
3.3-rc1), from then on it's only bugfixes to stabilize for release.

My soft limit patch missed this merge window, so the earliest target
is 3.4.  And that's fine, there are still things that need to be
evaluated, like kswapd now reclaiming with priority 0 and
nr_to_reclaim at ULONG_MAX, which Michal pointed out.  Or KAME's
concerns regarding direct soft reclaim and numa setups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
