Date: Wed, 05 Mar 2008 10:42:20 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 12/21] No Reclaim LRU Infrastructure
In-Reply-To: <1204643158.5338.5.camel@localhost>
References: <20080304192441.1EA2.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1204643158.5338.5.camel@localhost>
Message-Id: <20080305103545.1EAE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > +config NORECLAIM
> > > +	bool "Track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
> > > +	depends on EXPERIMENTAL && 64BIT
> > 
> > as far as I remembered, somebody said CONFIG_NORECLAIM is easy confusable.
> > may be..
> > 
> > IMHO insert "lru" word is better.
> > example,
> > 
> > config NORECLAIM_LRU
> > 	bool "Zone LRU of track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
> > 	depends on EXPERIMENTAL && 64BIT
> 
> OK.  But, I'd suggest the 'bool' description be something like:
> 
> config NORECLAIM_LRU
> 	bool "Add LRU list to track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"

That's nice. thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
