Date: Sat, 21 Sep 2002 16:31:51 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: overcommit stuff
Message-ID: <14599773.1032625910@[10.10.2.3]>
In-Reply-To: <3D8D0046.EF119E03@digeo.com>
References: <3D8D0046.EF119E03@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> running 10,000 tiobench threads I'm showing 23 gigs of
> `Commited_AS'.  Is this right?  Those pages are shared,
> and if they're not PROT_WRITEable then there's no way in
> which they can become unshared?   Seems to be excessively
> pessimistic?
> 
> Or is 2.5 not up to date?

It's also a global atomic counter that burns up a fair amount
of CPU time bouncing cachelines on the NUMA boxes ... even when 
overcommit is set to 1, and it's not used for anything other 
than meminfo ... any chance of this either becoming a per-cpu 
thing, or dying, or not being used when overcommit is 1?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
