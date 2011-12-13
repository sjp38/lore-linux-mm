Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 036B16B0260
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 09:05:29 -0500 (EST)
Date: Tue, 13 Dec 2011 15:05:12 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcg: keep root group unchanged if fail to create
 new
Message-ID: <20111213140511.GA1818@cmpxchg.org>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
 <alpine.LSU.2.00.1112111520510.2297@eggly>
 <20111212131118.GA15249@tiehlicka.suse.cz>
 <CAJd=RBAZT0zVnMm7i7P4J9Qg+LvTYh25RwFP7JZnN9dxwWp55g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBAZT0zVnMm7i7P4J9Qg+LvTYh25RwFP7JZnN9dxwWp55g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 12, 2011 at 09:49:18PM +0800, Hillf Danton wrote:
> On Mon, Dec 12, 2011 at 9:11 PM, Michal Hocko <mhocko@suse.cz> wrote:
> >
> > Hillf could you update the patch please?
> >
> Hi Michal,
> 
> Please review again, thanks.
> Hillf
> 
> ===CUT HERE===
> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: memcg: keep root group unchanged if fail to create new
> 
> If the request is to create non-root group and we fail to meet it, we should
> leave the root unchanged.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
