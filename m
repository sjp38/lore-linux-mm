Date: Mon, 2 Oct 2006 00:05:11 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20061001234858.fe91109e.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0> <20061001231811.26f91c47.pj@sgi.com>
 <Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
 <20061001234858.fe91109e.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Sun, 1 Oct 2006, Paul Jackson wrote:

> I'm not sure what you have in mind by "scale this."
> 

I'm talking about this:

+struct zonelist_faster {
+	nodemask_t fullnodes;		/* nodes recently lacking free memory */
+	unsigned long last_full_zap;	/* jiffies when fullnodes last zero'd */
+	unsigned short node_id[MAX_NUMNODES * MAX_NR_ZONES]; /* zone -> nid */
+};

With NODES_SHIFT equal to 10 as you recommend, you can't get away with an 
unsigned short there.  Likewise, your nodemask_t would need to be 128 
bytes.  So this doesn't scale appropriately when you simply change 
NODES_SHIFT.

> This speedup should apply regardless of how many nodes (fake or
> real or mixed) are present.
> 

It doesn't (see above).

> But whatever benefit this proposal has should be independent of the
> value of NODES_SHIFT.
> 

It's not (see above).

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
