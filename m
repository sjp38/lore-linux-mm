Date: Fri, 10 Mar 2006 16:33:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: drain_node_pages: interrupt latency reduction / optimization
In-Reply-To: <20060310162826.5f7a50e4.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603101629100.32555@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603101258290.29954@schroedinger.engr.sgi.com>
 <20060310160527.5ddfc610.akpm@osdl.org> <Pine.LNX.4.64.0603101605410.31461@schroedinger.engr.sgi.com>
 <20060310162826.5f7a50e4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > -		pset = zone_pcp(zone, smp_processor_id());
> > +		pset = zone_pcp(zone, raw_smp_processor_id());
> hm.  That replaces a runtime check with a comment.  If someone comes along
> and reuses this function wrongly they'll have a nasty subtle bug.
>
> IOW: it might be best to keep the smp_processor_id() check in there.

Ahh. The DEBUG_PREEMPT is much more intelligent now and checks for this in 
the right way.  I agree leave as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
