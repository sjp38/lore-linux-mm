Date: Tue, 3 Oct 2006 11:15:17 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061003111517.a5cc30ea.pj@sgi.com>
In-Reply-To: <20061002014121.28b759da.pj@sgi.com>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<20061001231811.26f91c47.pj@sgi.com>
	<Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
	<20061001234858.fe91109e.pj@sgi.com>
	<Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
	<20061002014121.28b759da.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rientjes@cs.washington.edu, linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

pj, responding to David:
> > With NODES_SHIFT equal to 10 as you recommend, you can't get away with an 
> > unsigned short there. 
> 
> Apparently it's time for me to be a stupid git again.  That's ok; I'm
> getting quite accustomed to it.
> 
> Could you spell out exactly why I can't get away with an unsigned short
> node_id if NODES_SHIFT is 10?


Is this still in your queue to respond to, David?

I'm still curious as to why I can't get away with an unsigned short there.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
