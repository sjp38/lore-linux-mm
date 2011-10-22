Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C9ABE6B002F
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 05:31:52 -0400 (EDT)
Date: Sat, 22 Oct 2011 11:31:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFD] Isolated memory cgroups again
Message-ID: <20111022093148.GB5497@tiehlicka.suse.cz>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
 <CALWz4ixxeFveibvqYa4cQR1a4fEBrTrTUFwm2iajk9mV0MEiTw@mail.gmail.com>
 <20111021024554.GC2589@tiehlicka.suse.cz>
 <20111021121759.429d8222.kamezawa.hiroyu@jp.fujitsu.com>
 <CALWz4iw9OGUNKjD5y2xGDGaesTjwUT5TOL2A7wDd5apy4M5fnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iw9OGUNKjD5y2xGDGaesTjwUT5TOL2A7wDd5apy4M5fnw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

On Fri 21-10-11 13:00:18, Ying Han wrote:
[...]
> The logic is based on reclaim priority, and we skip reclaim from certain
> memcg(under soft limit) before getting down to DEF_PRIORITY - 3.

OK, I guess I remember something from the earlier memcg naturalization
patch set discussions. This will still not help much for my case as the
bigger memory pressure would cause reclaim also from the soft unlimited
group which I would like to prevent.
The other thing about soft limit only reclaim from the global reclaim is
that currently all created memcgs are soft unlimited by default which
might lead to unexpected results. Can we come up with a reasonable soft
limit default?

[...]
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
