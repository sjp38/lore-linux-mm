Date: Sun, 1 Oct 2006 23:31:20 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20061001231811.26f91c47.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0> <20061001231811.26f91c47.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Sun, 1 Oct 2006, Paul Jackson wrote:
> Perhaps instead of a single 'nodemask_t fullnodes', I need a small
> array of these nodemasks, one per MAX_NR_ZONES.  Then I could select
> which fullnodes nodemask to check by taking my index into the node_id[]
> array, modulo MAX_NR_ZONES.
> 

It would be nice to be able to scale this so that the speed-up works 
efficiently for numa=fake=256 (after NODES_SHIFT is increased from 6 to 8 
on x86_64).

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
