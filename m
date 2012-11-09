Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 10C3E6B004D
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 04:06:40 -0500 (EST)
Date: Fri, 9 Nov 2012 09:06:35 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kswapd0: excessive CPU usage
Message-ID: <20121109090635.GG8218@suse.de>
References: <5077434D.7080008@suse.cz>
 <50780F26.7070007@suse.cz>
 <20121012135726.GY29125@suse.de>
 <507BDD45.1070705@suse.cz>
 <20121015110937.GE29125@suse.de>
 <5093A3F4.8090108@redhat.com>
 <5093A631.5020209@suse.cz>
 <509422C3.1000803@suse.cz>
 <509C84ED.8090605@linux.vnet.ibm.com>
 <509CB9D1.6060704@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <509CB9D1.6060704@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zdenek Kabelac <zkabelac@redhat.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

On Fri, Nov 09, 2012 at 09:07:45AM +0100, Zdenek Kabelac wrote:
> >fe2c2a106663130a5ab45cb0e3414b52df2fff0c is the first bad commit
> >commit fe2c2a106663130a5ab45cb0e3414b52df2fff0c
> >Author: Rik van Riel <riel@redhat.com>
> >Date:   Wed Mar 21 16:33:51 2012 -0700
> >
> >     vmscan: reclaim at order 0 when compaction is enabled
> >...
> >
> >This is plausible since the issue seems to be in the kswapd + compaction
> >realm.  I've yet to figure out exactly what about this commit results in
> >kswapd spinning.
> >
> >I would be interested if someone can confirm this finding.
> >
> >--
> >Seth
> >
> 
> 
> On my system 3.7-rc4 the problem seems to be effectively solved by
> revert patch: https://lkml.org/lkml/2012/11/5/308
> 

Ok, while there is still a question on whether it's enough I think it's
sensible to at least start with the obvious one.

Thanks very much.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
